import { test } from '../helpers/fixtures'
import { shoot } from '../helpers/screenshot'
import { env } from '../helpers/env'
import { login, postMessage, expectMessage } from '../helpers/mattermost'

const user = env('PLAYWRIGHT_DEVICE_USER')
const password = env('PLAYWRIGHT_DEVICE_PASSWORD')
const message = 'test message'

test.describe('mattermost smoke', () => {
  test('login, post and read a message', async ({ page }, testInfo) => {
    await login(page, user, password)
    await shoot(page, testInfo, 'chat')
    await postMessage(page, message)
    await shoot(page, testInfo, 'post-message')
    await expectMessage(page, message)
    await shoot(page, testInfo, 'check-message')
  })
})
