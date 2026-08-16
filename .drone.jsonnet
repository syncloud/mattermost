local name = 'mattermost';
local postgresql = '15-bullseye';
local platform = '26.08.01';
local playwright = 'mcr.microsoft.com/playwright:v1.48.2-jammy';
local store_publisher = 'stable-346';
local mattermost = '11.10.0-syncloud';
local python = '3.12-slim-bookworm';
local golang = '1.25';
local debian = 'bookworm-slim';
local distro_default = 'bookworm';
local distros = ['bookworm'];

local platform_image(distro) =
  'syncloud/platform-' + distro + ':' + platform;

local build(arch, test_ui) = [{
  kind: 'pipeline',
  type: 'docker',
  name: arch,
  platform: {
    os: 'linux',
    arch: arch,
  },
  steps: [
    {
      name: 'cli',
      image: 'golang:' + golang,
      commands: [
        './cli/build.sh',
      ],
    },
    {
      name: 'postgresql',
      image: 'postgres:' + postgresql,
      commands: [
        './postgresql/build.sh',
      ],
    },
    {
      name: 'mattermost',
      image: 'debian:' + debian,
      commands: [
        './mattermost/download.sh ' + arch + ' ' + mattermost,
      ],
    },
  ] + [
    {
      name: 'postgresql test ' + distro,
      image: platform_image(distro),
      commands: [
        './postgresql/test.sh',
      ],
    }
    for distro in distros
  ] + [
    {
      name: 'mattermost test ' + distro,
      image: platform_image(distro),
      commands: [
        './mattermost/test.sh',
      ],
    }
    for distro in distros
  ] + [
    {
      name: 'package',
      image: 'debian:' + debian,
      commands: [
        './package.sh ' + name + ' $DRONE_BUILD_NUMBER',
      ],
    },
  ] + [
    {
      name: 'test ' + distro,
      image: 'python:' + python,
      commands: [
        './ci/test.sh test.py ' + distro + ' ' + name,
      ],
    }
    for distro in distros
  ] + (if test_ui then [
         {
           name: 'e2e',
           image: playwright,
           commands: [
             './test/e2e/run.sh e2e specs/01-smoke.spec.ts',
           ],
         },
         {
           name: 'test-upgrade-prev',
           image: 'python:' + python,
           commands: [
             './ci/test.sh upgrade_prev.py ' + distro_default + ' ' + name,
           ],
         },
         {
           name: 'e2e-before-upgrade',
           image: playwright,
           commands: [
             './test/e2e/run.sh e2e-before-upgrade specs/02-pre-upgrade.spec.ts',
           ],
         },
         {
           name: 'test-upgrade',
           image: 'python:' + python,
           commands: [
             './ci/test.sh upgrade.py ' + distro_default + ' ' + name,
           ],
         },
         {
           name: 'e2e-after-upgrade',
           image: playwright,
           commands: [
             './test/e2e/run.sh e2e-after-upgrade specs/03-post-upgrade.spec.ts',
           ],
         },
       ] else []) + [
    {
      name: 'publish',
      image: 'syncloud/store-publisher:' + store_publisher,
      environment: {
        SYNCLOUD_TOKEN: { from_secret: 'SYNCLOUD_TOKEN' },
      },
      command: ['snap', '-c', '${DRONE_BRANCH}'],
      when: {
        branch: ['master', 'stable'],
        event: ['push'],
      },
    },
    {
      name: 'artifact',
      image: 'appleboy/drone-scp:1.6.4',
      settings: {
        host: { from_secret: 'artifact_host' },
        username: 'artifact',
        key: { from_secret: 'artifact_key' },
        timeout: '2m',
        command_timeout: '2m',
        target: '/home/artifact/repo/' + name + '/${DRONE_BUILD_NUMBER}-' + arch,
        source: ['artifact/*'],
        strip_components: 1,
      },
      when: {
        status: ['failure', 'success'],
      },
    },
  ],
  trigger: {
    event: ['push'],
  },
  services: [
    {
      name: name + '.' + distro + '.com',
      image: platform_image(distro),
      privileged: true,
      volumes: [
        { name: 'dbus', path: '/var/run/dbus' },
        { name: 'dev', path: '/dev' },
      ],
    }
    for distro in distros
  ],
  volumes: [
    { name: 'dbus', host: { path: '/var/run/dbus' } },
    { name: 'dev', host: { path: '/dev' } },
  ],
}];

build('amd64', true) +
build('arm64', false)
