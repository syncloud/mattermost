import { Locator, Page, expect } from '@playwright/test'

const ORGANIZATION = 'testorg'

async function clickIfVisible(locator: Locator, timeout: number): Promise<boolean> {
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
  await clickIfVisible(page.getByText('View in Browser'), 30_000)
  await waitLoaded(page)
}

export async function loginLdap(page: Page, user: string, password: string) {
  const ldap = page.getByText(/AD\/LDAP Credential/)
  await ldap.scrollIntoViewIfNeeded()
  await ldap.click()
  await waitLoaded(page)

  await page.locator('#input_loginId').fill(user)
  await page.locator('#input_password-input').fill(password)
  await page.locator('[data-testid="saveSetting"]').click()
}

export async function completeOnboarding(page: Page) {
  const organization = page.locator('[data-testid="continue"]')
  const composer = page.locator('[data-testid="post_textbox"]')
  await expect(organization.or(composer).first()).toBeVisible()

  if (!(await organization.isVisible())) {
    return
  }

  await page.locator('input.Organization__input').fill(ORGANIZATION)
  await organization.click()

  const plugins = page.locator('.Plugins-body')
  if (await clickIfVisible(plugins.getByRole('button', { name: 'Continue' }), 60_000)) {
    await expect(plugins).toBeHidden()
  }

  const invite = page.locator('.InviteMembers__submit')
  if (await clickIfVisible(invite.getByRole('button', { name: 'Finish setup' }), 60_000)) {
    await expect(invite).toBeHidden()
  }
}

export async function dismissModals(page: Page) {
  await clickIfVisible(page.getByRole('button', { name: 'No thanks' }), 5_000)
  await clickIfVisible(page.locator('button.close').first(), 5_000)
}

export async function waitChat(page: Page) {
  await expect(page.locator('[data-testid="post_textbox"]')).toBeVisible({ timeout: 240_000 })
  await dismissModals(page)
}

export async function postMessage(page: Page, text: string) {
  await dismissModals(page)
  await page.locator('[data-testid="post_textbox"]').fill(text)
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
