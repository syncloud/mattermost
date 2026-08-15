import { Locator, Page, expect } from '@playwright/test'

const OPTIONAL_TIMEOUT = 20_000

async function clickIfVisible(locator: Locator, timeout = OPTIONAL_TIMEOUT): Promise<boolean> {
  try {
    await locator.waitFor({ state: 'visible', timeout })
  } catch {
    return false
  }
  await locator.click()
  return true
}

export async function waitLoaded(page: Page) {
  await expect(page.locator('#initialPageLoadingScreen')).toBeHidden()
}

export async function viewInBrowser(page: Page) {
  await waitLoaded(page)
  await clickIfVisible(page.getByText('View in Browser').first())
  await waitLoaded(page)
}

export async function loginLdap(page: Page, user: string, password: string) {
  const ldap = page.getByText(/AD\/LDAP Credential|LDAP Credential/).first()
  await ldap.scrollIntoViewIfNeeded()
  await ldap.click()
  await waitLoaded(page)

  await page.locator('#input_loginId').fill(user)
  await page.locator('#input_password-input').fill(password)
  await page.getByText('Log in', { exact: true }).first().click()
}

export async function completeOnboarding(page: Page) {
  const org = page.locator('input[placeholder="Organization name"]')
  if (await clickIfVisible(org)) {
    await org.fill('testorg')
    await page.getByText('Continue', { exact: true }).first().click()
  }

  const tools = page.getByText('What tools do you use?').first()
  try {
    await tools.waitFor({ state: 'visible', timeout: OPTIONAL_TIMEOUT })
    await page
      .locator('xpath=//span[.="What tools do you use?"]/../..//span[.="Continue"]')
      .click()
    await expect(tools).toBeHidden()
  } catch {}

  const invite = page.getByText('Invite your team members').first()
  try {
    await invite.waitFor({ state: 'visible', timeout: OPTIONAL_TIMEOUT })
    await page.getByText('Finish setup', { exact: true }).first().click()
    await expect(invite).toBeHidden()
  } catch {}
}

export async function dismissModals(page: Page) {
  await clickIfVisible(page.getByText('No thanks', { exact: true }).first(), 5_000)
  await clickIfVisible(page.locator('button.close').first(), 5_000)
}

export async function waitChat(page: Page) {
  await expect(page.locator('#post_textbox')).toBeVisible()
  await dismissModals(page)
}

export async function postMessage(page: Page, text: string) {
  await dismissModals(page)
  await page.locator('#post_textbox').fill(text)
  await page.locator('[data-testid="SendMessageButton"]').click()
}

export async function expectMessage(page: Page, text: string) {
  await dismissModals(page)
  await expect(page.locator('.post-message__text', { hasText: text }).first()).toBeVisible()
}

export async function login(page: Page, user: string, password: string) {
  await page.goto('/')
  await viewInBrowser(page)
  await loginLdap(page, user, password)
  await completeOnboarding(page)
  await waitChat(page)
}
