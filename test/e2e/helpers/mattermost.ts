import { Locator, Page, expect } from '@playwright/test'
import { CurrentUser } from './current_user'
import { InstallPluginRequest } from './install_plugin_request'
import { PluginStatus } from './plugin_status'

const ORGANIZATION = 'testorg'
const PLUGIN_RUNNING = 2

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
  const modal = page.locator('#genericModal')
  for (let i = 0; i < 3; i++) {
    if (!(await clickIfVisible(modal.locator('button.close'), 5_000))) {
      break
    }
    await expect(modal).toBeHidden()
  }
  await clickIfVisible(page.locator('[data-cy="onboarding-task-list-overlay"]'), 5_000)
}

export async function waitChat(page: Page) {
  const composer = page.locator('[data-testid="post_textbox"]')
  try {
    await expect(composer).toBeVisible({ timeout: 120_000 })
  } catch {
    await page.goto('/')
    await expect(composer).toBeVisible({ timeout: 120_000 })
  }
  await dismissModals(page)
}

export async function postMessage(page: Page, text: string) {
  await dismissModals(page)
  await page.locator('[data-testid="post_textbox"]').fill(text)
  await dismissModals(page)
  await page.locator('[data-testid="SendMessageButton"]').click()
}

export async function expectMessage(page: Page, text: string) {
  await dismissModals(page)
  await expect(page.locator('.post-message__text', { hasText: text }).first()).toBeVisible()
}

export async function signInAuthelia(page: Page, user: string, password: string) {
  await page.locator('#username-textfield').fill(user)
  await page.locator('#password-textfield').fill(password)
  await page.locator('#sign-in-button').click()
}

export async function openLogin(page: Page): Promise<Locator> {
  await page.goto('/')
  await viewInBrowser(page)
  const sso = page.getByTestId('openid')
  await expect(sso).toBeVisible({ timeout: 60_000 })
  return sso
}

export async function login(page: Page, user: string, password: string) {
  await (await openLogin(page)).click()
  await signInAuthelia(page, user, password)
  await completeOnboarding(page)
  await waitChat(page)
}

export async function currentUser(page: Page): Promise<CurrentUser> {
  const response = await page.request.get('/api/v4/users/me')
  expect(response.status()).toBe(200)
  return (await response.json()) as CurrentUser
}

async function csrfHeaders(page: Page): Promise<Record<string, string>> {
  const cookies = await page.context().cookies()
  const csrf = cookies.find((cookie) => cookie.name === 'MMCSRF')
  expect(csrf).toBeDefined()
  return { 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': csrf!.value }
}

export async function installMarketplacePlugin(page: Page, id: string) {
  const headers = await csrfHeaders(page)
  const request: InstallPluginRequest = { id }
  const install = await page.request.post('/api/v4/plugins/marketplace', { headers, data: request, timeout: 300_000 })
  expect(install.status(), await install.text()).toBe(201)
  const enable = await page.request.post(`/api/v4/plugins/${id}/enable`, { headers })
  expect(enable.status(), await enable.text()).toBe(200)
}

export async function pluginState(page: Page, id: string): Promise<number | undefined> {
  const response = await page.request.get('/api/v4/plugins/statuses')
  expect(response.status()).toBe(200)
  const statuses = (await response.json()) as PluginStatus[]
  return statuses.find((status) => status.plugin_id === id)?.state
}

export async function expectPluginRunning(page: Page, id: string) {
  await expect.poll(() => pluginState(page, id), { timeout: 300_000, intervals: [5_000] }).toBe(PLUGIN_RUNNING)
}
