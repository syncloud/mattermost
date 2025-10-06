import time
from os.path import dirname, join
from subprocess import check_output

import pytest
import requests
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from syncloudlib.integration.hosts import add_host_alias

DIR = dirname(__file__)
TMP_DIR = '/tmp/syncloud/ui'


@pytest.fixture(scope="session")
def module_setup(request, device, artifact_dir, ui_mode, driver, selenium):
    def teardown():
        device.activated()
        device.run_ssh('mkdir -p {0}'.format(TMP_DIR), throw=False)
        device.run_ssh('journalctl > {0}/journalctl.ui.{1}.log'.format(TMP_DIR, ui_mode), throw=False)
        device.run_ssh('cat /var/snap/platform/current/config/authelia/config.yml > {0}/authelia.config.ui.log'.format(TMP_DIR), throw=False)
        device.scp_from_device('{0}/*'.format(TMP_DIR), join(artifact_dir, 'log'))
        check_output('cp /videos/* {0}'.format(artifact_dir), shell=True)
        check_output('chmod -R a+r {0}'.format(artifact_dir), shell=True)
        selenium.log()

    request.addfinalizer(teardown)


def test_start(module_setup, app, domain, device_host):
    add_host_alias(app, device_host, domain)


@pytest.mark.flaky(retries=20, delay=5)
def test_visible_through_platform(app_domain):
    response = requests.get('https://{0}'.format(app_domain), verify=False)
    assert response.status_code == 200, response.text


def test_login(selenium, device_user, device_password):
    selenium.open_app()
    selenium.find_by(By.XPATH, "//span[contains(.,'View in Browser')]").click()
    selenium.find_by(By.XPATH, "//span[contains(.,'LDAP Credential')]").click()
    selenium.find_by(By.ID, "input_loginId").send_keys(device_user)
    password = selenium.find_by(By.ID, "input_password-input")
    password.send_keys(device_password)
    selenium.screenshot('login')
    #password.send_keys(Keys.RETURN)
    #selenium.find_by(By.ID, "sign-in-button").click()
    #selenium.find_by(By.ID, "accept-button").click()
    selenium.find_by(By.XPATH, "//span[contains(.,'Log in')]").click()
    selenium.find_by(By.XPATH, "//input[@placeholder='Organization name']").send_keys("testorg")
    selenium.screenshot('org')
    selenium.click_by(By.XPATH, "//span[.='Continue']")

    selenium.find_by(By.XPATH, "//span[.='What tools do you use?']")
    selenium.find_by(By.XPATH, "//span[.='GitHub']")
    selenium.find_by(By.XPATH, "//span[.='GitLab']")
    selenium.find_by(By.XPATH, "//span[.='Skip']")
    selenium.screenshot('tools')
    selenium.click_by(By.XPATH, '//span[.="What tools do you use?"]/../..//span[.="Continue"]')
    # selenium.click_by(By.XPATH, "//span[.='Continue']")

    selenium.find_by(By.XPATH, "//span[.='Invite your team members']")
    selenium.screenshot('invite')
    selenium.click_by(By.XPATH, "//span[.='Finish setup']")

    selenium.find_by(By.XPATH, "//span[contains(.,'Experience a better way')]")
    selenium.screenshot('experience')
    #selenium.click_by(By.XPATH, "//span[contains(.,'Experience a better way')]/../../../..//span'")
    selenium.click_by(By.XPATH, "//button[@class='close']")

    selenium.find_by(By.XPATH, "//span[contains(.,'Welcome to Town Square')]")
    #selenium.screenshot('welcome')
    #selenium.click_by(By.XPATH, "//button[@class='close']")
    #selenium.invisible_by(By.XPATH, "//span[.='Visible to Admins only']")
    selenium.screenshot('chat')

def test_message(selenium):

    selenium.clickable_by(By.XPATH, "//textarea[@id='post_textbox']").send_keys("test message")
    selenium.click_by(By.XPATH, "//button[@data-testid='SendMessageButton']")
    selenium.find_by(By.XPATH, "//div[@class='post-message__text' and .='test message']")
    selenium.screenshot('message')
