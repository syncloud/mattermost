import { test } from '../helpers/fixtures'
import { shoot } from '../helpers/screenshot'
import { env } from '../helpers/env'
import { login, postMessage, expectMessage } from '../helpers/mattermost'

const user = env('PLAYWRIGHT_DEVICE_USER')
const password = env('PLAYWRIGHT_DEVICE_PASSWORD')
const message = 'pre upgrade message'

test.describe('mattermost pre-upgrade', () => {
  test('seed a message on the released version', async ({ page }, testInfo) => {
    await login(page, user, password)
    await shoot(page, testInfo, 'pre-upgrade-chat')
    await postMessage(page, message)
    await expectMessage(page, message)
    await shoot(page, testInfo, 'pre-upgrade-message')
  })
})
