import { test, expect } from '../helpers/fixtures'
import { shoot } from '../helpers/screenshot'
import { env } from '../helpers/env'
import { login, openLogin, currentUser, postMessage, expectMessage, installMarketplacePlugin, expectPluginRunning } from '../helpers/mattermost'

const user = env('PLAYWRIGHT_DEVICE_USER')
const password = env('PLAYWRIGHT_DEVICE_PASSWORD')
const message = 'test message'

test.describe('mattermost smoke', () => {
  test('login page offers syncloud sign in', async ({ page }, testInfo) => {
    const sso = await openLogin(page)
    await expect(sso).toContainText('Syncloud')
    await shoot(page, testInfo, 'login')
  })

  test('syncloud sign in, post and read a message', async ({ page }, testInfo) => {
    await login(page, user, password)
    await shoot(page, testInfo, 'chat')
    await postMessage(page, message)
    await shoot(page, testInfo, 'post-message')
    await expectMessage(page, message)
    await shoot(page, testInfo, 'check-message')
  })

  test('syncloud admin is a system admin with an openid account', async ({ page }) => {
    await login(page, user, password)
    const me = await currentUser(page)
    expect(me.username).toBe(user)
    expect(me.auth_service).toBe('openid')
    expect(me.roles.split(' ')).toContain('system_admin')
  })

  test('bundled calls and agents plugins are running', async ({ page }) => {
    await login(page, user, password)
    await expectPluginRunning(page, 'com.mattermost.calls')
    await expectPluginRunning(page, 'mattermost-ai')
  })

  test('admin installs a plugin from the marketplace', async ({ page }) => {
    test.setTimeout(900_000)
    await login(page, user, password)
    await installMarketplacePlugin(page, 'jira')
    await expectPluginRunning(page, 'jira')
  })
})
