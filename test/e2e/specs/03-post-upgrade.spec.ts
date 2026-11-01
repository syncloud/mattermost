import { test, expect } from '../helpers/fixtures'
import { shoot } from '../helpers/screenshot'
import { env } from '../helpers/env'
import { login, currentUser, postMessage, expectMessage } from '../helpers/mattermost'

const user = env('PLAYWRIGHT_DEVICE_USER')
const password = env('PLAYWRIGHT_DEVICE_PASSWORD')
const preMessage = 'pre upgrade message'
const postMessageText = 'post upgrade message'

test.describe('mattermost post-upgrade', () => {
  test('syncloud account and messages survive the upgrade', async ({ page }, testInfo) => {
    await login(page, user, password)
    await shoot(page, testInfo, 'post-upgrade-chat')
    const me = await currentUser(page)
    expect(me.username).toBe(user)
    expect(me.auth_service).toBe('openid')
    expect(me.roles.split(' ')).toContain('system_admin')
    await expectMessage(page, preMessage)
    await shoot(page, testInfo, 'pre-upgrade-message-verified')
  })

  test('posting still works after upgrade', async ({ page }, testInfo) => {
    await login(page, user, password)
    await postMessage(page, postMessageText)
    await expectMessage(page, postMessageText)
    await expectMessage(page, preMessage)
    await shoot(page, testInfo, 'post-upgrade-message')
  })
})
