local name = 'mattermost';
local browser = 'chrome';
local version = '10.3.1';
local nginx = '1.24.0';
local postgresql = "15-bullseye";
local node = "18-bookworm-slim";
local platform = '22.02';
local selenium = '4.21.0-20240517';
local deployer = 'https://github.com/syncloud/store/releases/download/4/syncloud-release';
local mattermost = '10.12.0-syncloud';
local python = '3.9-slim-buster';

local build(arch, test_ui, dind) = [{
  kind: 'pipeline',
  type: 'docker',
  name: arch,
  platform: {
    os: 'linux',
    arch: arch,
  },
  steps: [
   {
             name: 'version',
             image: 'debian:bookworm-slim',
             commands: [
               'echo $DRONE_BUILD_NUMBER > version',
             ],
           },
           {
             name: 'cli',
             image: 'golang:1.23',
             commands: [
               'cd cli',
               'CGO_ENABLED=0 go build -o ../build/snap/meta/hooks/install ./cmd/install',
               'CGO_ENABLED=0 go build -o ../build/snap/meta/hooks/configure ./cmd/configure',
               'CGO_ENABLED=0 go build -o ../build/snap/meta/hooks/pre-refresh ./cmd/pre-refresh',
               'CGO_ENABLED=0 go build -o ../build/snap/meta/hooks/post-refresh ./cmd/post-refresh',
               'CGO_ENABLED=0 go build -o ../build/snap/bin/cli ./cmd/cli',
             ],
           },
  
  {
            name: "postgresql",
            image: "postgres:" + postgresql,
            commands: [
                "./postgresql/build.sh"
            ]
           
        },
        {
            name: "postgresql test",
            image: 'syncloud/platform-buster-' + arch + ':' + platform,
            commands: [
                "./postgresql/test.sh"
            ]
        },
    {
      name: 'mattermost',
      image: 'debian:buster-slim',
      commands: [
        './mattermost/download.sh ' + arch + ' ' + mattermost,
      ],
    },

    {
      name: 'mattermost test',
      image: 'syncloud/platform-buster-' + arch + ':' + platform,
      commands: [
        './mattermost/test.sh',
      ],
    },
   
    {
      name: 'package',
      image: 'debian:buster-slim',
      commands: [
        'VERSION=$(cat version)',
        './package.sh ' + name + ' $VERSION ',
      ],
    },
    {
      name: 'test',
      image: 'python:' + python,
      commands: [
        'APP_ARCHIVE_PATH=$(realpath $(cat package.name))',
        'cd test',
        './deps.sh',
        'py.test -rA -vvvvv -x -s test.py --distro=buster --domain=buster.com --app-archive-path=$APP_ARCHIVE_PATH --device-host=' + name + '.buster.com --app=' + name + ' --arch=' + arch,
      ],
    },
  ] + (if test_ui then [
    {
            name: "selenium",
            image: "selenium/standalone-" + browser + ":" + selenium,
            detach: true,
            environment: {
                SE_NODE_SESSION_TIMEOUT: "999999",
                START_XVFB: "true"
            },
               volumes: [{
                name: "shm",
                path: "/dev/shm"
            }],
            commands: [
                "cat /etc/hosts",
                "getent hosts " + name + ".buster.com | sed 's/" + name +".buster.com/auth.buster.com/g' | sudo tee -a /etc/hosts",
                "cat /etc/hosts",
                "/opt/bin/entry_point.sh"
            ]
         },
     {
           name: 'selenium-video',
           image: 'selenium/video:ffmpeg-6.1.1-20240517',
           detach: true,
           environment: {
             DISPLAY_CONTAINER_NAME: 'selenium',
             FILE_NAME: 'video.mkv',
           },
           volumes: [
             {
               name: 'shm',
               path: '/dev/shm',
             },
             {
               name: 'videos',
               path: '/videos',
             },
           ],
         },
         {
           name: 'test-ui',
           image: 'python:' + python,
           commands: [
             'cd test',
             './deps.sh',
             'py.test -x -s ui.py --distro=buster --ui-mode=desktop --domain=buster.com --device-host=' + name + '.buster.com --app=' + name + ' --browser-height=2000 --browser=' + browser,
           ],
           volumes: [{
             name: 'videos',
             path: '/videos',
           }],
         },

       ] else []) + [
    {
      name: 'test-upgrade',
      image: 'python:' + python,
      commands: [
        'APP_ARCHIVE_PATH=$(realpath $(cat package.name))',
        'cd test',
        './deps.sh',
        'py.test -x -s upgrade.py --distro=buster --ui-mode=desktop --domain=buster.com --app-archive-path=$APP_ARCHIVE_PATH --device-host=' + name + '.buster.com --app=' + name + ' --browser=' + browser,
      ],
    },
    {
      name: 'upload',
      image: 'debian:buster-slim',
      environment: {
        AWS_ACCESS_KEY_ID: {
          from_secret: 'AWS_ACCESS_KEY_ID',
        },
        AWS_SECRET_ACCESS_KEY: {
          from_secret: 'AWS_SECRET_ACCESS_KEY',
        },
        SYNCLOUD_TOKEN: {
          from_secret: 'SYNCLOUD_TOKEN',
        },
      },
      commands: [
        'PACKAGE=$(cat package.name)',
        'apt update && apt install -y wget',
        'wget ' + deployer + '-' + arch + ' -O release --progress=dot:giga',
        'chmod +x release',
        './release publish -f $PACKAGE -b $DRONE_BRANCH',
      ],
      when: {
        branch: ['stable', 'master'],
        event: ['push'],
      },
    },
    {
      name: 'promote',
      image: 'debian:buster-slim',
      environment: {
        AWS_ACCESS_KEY_ID: {
          from_secret: 'AWS_ACCESS_KEY_ID',
        },
        AWS_SECRET_ACCESS_KEY: {
          from_secret: 'AWS_SECRET_ACCESS_KEY',
        },
        SYNCLOUD_TOKEN: {
          from_secret: 'SYNCLOUD_TOKEN',
        },
      },
      commands: [
        'apt update && apt install -y wget',
        'wget ' + deployer + '-' + arch + ' -O release --progress=dot:giga',
        'chmod +x release',
        './release promote -n ' + name + ' -a $(dpkg --print-architecture)',
      ],
      when: {
        branch: ['stable'],
        event: ['push'],
      },
    },
    {
      name: 'artifact',
      image: 'appleboy/drone-scp:1.6.4',
      settings: {
        host: {
          from_secret: 'artifact_host',
        },
        username: 'artifact',
        key: {
          from_secret: 'artifact_key',
        },
        timeout: '2m',
        command_timeout: '2m',
        target: '/home/artifact/repo/' + name + '/${DRONE_BUILD_NUMBER}-' + arch,
        source: 'artifact/*',
        strip_components: 1,
      },
      when: {
        status: ['failure', 'success'],
        event: ['push'],
      },
    },
  ],
  trigger: {
    event: [
      'push',
      'pull_request',
    ],
  },
  services: [
    {
      name: 'docker',
      image: 'docker:' + dind,
      privileged: true,
      volumes: [
        {
          name: 'dockersock',
          path: '/var/run',
        },
      ],
    },
    {
      name: name + '.buster.com',
      image: 'syncloud/platform-buster-' + arch + ':' + platform,
      privileged: true,
      volumes: [
        {
          name: 'dbus',
          path: '/var/run/dbus',
        },
        {
          name: 'dev',
          path: '/dev',
        },
      ],
    },
  ],
  volumes: [
    {
      name: 'dbus',
      host: {
        path: '/var/run/dbus',
      },
    },
    {
      name: 'dev',
      host: {
        path: '/dev',
      },
    },
    {
      name: 'shm',
      temp: {},
    },
    {
      name: 'dockersock',
      temp: {},
    },
    {
      name: 'videos',
      temp: {},
    },
  ],
}];

build('amd64', true, '20.10.21-dind') +
build('arm64', false, '20.10.21-dind')
