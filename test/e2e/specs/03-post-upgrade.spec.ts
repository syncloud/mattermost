import { test } from '../helpers/fixtures'
import { shoot } from '../helpers/screenshot'
import { env } from '../helpers/env'
import { login, postMessage, expectMessage } from '../helpers/mattermost'

const user = env('PLAYWRIGHT_DEVICE_USER')
const password = env('PLAYWRIGHT_DEVICE_PASSWORD')
const preMessage = 'pre upgrade message'
const postMessageText = 'post upgrade message'

test.describe('mattermost post-upgrade', () => {
  test('pre-upgrade message survives and posting still works', async ({ page }, testInfo) => {
    await login(page, user, password)
    await shoot(page, testInfo, 'post-upgrade-chat')
    await expectMessage(page, preMessage)
    await shoot(page, testInfo, 'pre-upgrade-message-verified')
    await postMessage(page, postMessageText)
    await expectMessage(page, postMessageText)
    await expectMessage(page, preMessage)
    await shoot(page, testInfo, 'post-upgrade-message')
  })
})
