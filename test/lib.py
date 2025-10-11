import time
from os.path import dirname, join
from subprocess import check_output

import pytest
import requests
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from syncloudlib.integration.hosts import add_host_alias


def login_prev(mode, selenium, device_user, device_password):
    selenium.find_by(By.XPATH, "//span[contains(.,'View in Browser')]").click()
    selenium.invisible_by(By.XPATH, "//span[contains(.,'View in Browser')]")
    selenium.screenshot(mode+'-ldap')
    selenium.click_by(By.XPATH, "//span[contains(.,'LDAP Credential')]")
    selenium.find_by(By.ID, "input_loginId").send_keys(device_user)
    password = selenium.find_by(By.ID, "input_password-input")
    password.send_keys(device_password)
    selenium.screenshot(mode+'-login')
    #password.send_keys(Keys.RETURN)
    #selenium.find_by(By.ID, "sign-in-button").click()
    #selenium.find_by(By.ID, "accept-button").click()
    selenium.find_by(By.XPATH, "//span[contains(.,'Log in')]").click()
    selenium.find_by(By.XPATH, "//input[@placeholder='Organization name']").send_keys("testorg")
    selenium.screenshot(mode+'-org')
    selenium.click_by(By.XPATH, "//span[.='Continue']")

    selenium.find_by(By.XPATH, "//span[.='What tools do you use?']")
    selenium.find_by(By.XPATH, "//span[.='GitHub']")
    selenium.find_by(By.XPATH, "//span[.='GitLab']")
    selenium.find_by(By.XPATH, "//span[.='Skip']")
    selenium.screenshot(mode+'-tools')
    selenium.click_by(By.XPATH, '//span[.="What tools do you use?"]/../..//span[.="Continue"]')
    selenium.invisible_by(By.XPATH, "//span[.='What tools do you use?']")
    # selenium.click_by(By.XPATH, "//span[.='Continue']")

    selenium.find_by(By.XPATH, "//span[.='Invite your team members']")
    selenium.screenshot(mode+'-invite')
    selenium.click_by(By.XPATH, "//span[.='Finish setup']")
    selenium.invisible_by(By.XPATH, "//span[.='Invite your team members']")

    #selenium.find_by(By.XPATH, "//span[contains(.,'Experience a better way')]")
    #selenium.screenshot(mode+'-experience')
    #selenium.click_by(By.XPATH, "//span[contains(.,'Experience a better way')]/../../../..//span'")
    #selenium.click_by(By.XPATH, "//button[@class='close']")
    #selenium.invisible_by(By.XPATH, "//span[contains(.,'Experience a better way')]")
    selenium.find_by(By.XPATH, "//span[contains(.,'Visible to Admins only')]")
    selenium.click_by(By.XPATH, "//span[contains(.,'Next')]")
    selenium.invisible_by(By.XPATH, "//span[contains(.,'Visible to Admins only')]")
 
    selenium.find_by(By.XPATH, "//span[contains(.,'Welcome to Town Square')]")
    #selenium.screenshot(mode+'-welcome')
    #selenium.click_by(By.XPATH, "//button[@class='close']")
    #selenium.invisible_by(By.XPATH, "//span[.='Visible to Admins only']")
    #selenium.click_by(By.XPATH, "//span[contains(.,'No thanks')]")
    selenium.invisible_by(By.XPATH, "//span[contains(.,'No thanks')]")

    selenium.screenshot(mode+'-chat')


def login_next(mode, selenium, device_user, device_password):
    selenium.find_by(By.XPATH, "//span[contains(.,'View in Browser')]").click()
    selenium.invisible_by(By.XPATH, "//span[contains(.,'View in Browser')]")
    selenium.screenshot(mode+'-ldap')
    selenium.click_by(By.XPATH, "//span[contains(.,'LDAP Credential')]")
    selenium.find_by(By.ID, "input_loginId").send_keys(device_user)
    password = selenium.find_by(By.ID, "input_password-input")
    password.send_keys(device_password)
    selenium.screenshot(mode+'-login')
    #password.send_keys(Keys.RETURN)
    #selenium.find_by(By.ID, "sign-in-button").click()
    #selenium.find_by(By.ID, "accept-button").click()
    selenium.find_by(By.XPATH, "//span[contains(.,'Log in')]").click()
    selenium.find_by(By.XPATH, "//input[@placeholder='Organization name']").send_keys("testorg")
    selenium.screenshot(mode+'-org')
    selenium.click_by(By.XPATH, "//span[.='Continue']")

    selenium.find_by(By.XPATH, "//span[.='What tools do you use?']")
    selenium.find_by(By.XPATH, "//span[.='GitHub']")
    selenium.find_by(By.XPATH, "//span[.='GitLab']")
    selenium.find_by(By.XPATH, "//span[.='Skip']")
    selenium.screenshot(mode+'-tools')
    selenium.click_by(By.XPATH, '//span[.="What tools do you use?"]/../..//span[.="Continue"]')
    selenium.invisible_by(By.XPATH, "//span[.='What tools do you use?']")
    # selenium.click_by(By.XPATH, "//span[.='Continue']")

    selenium.find_by(By.XPATH, "//span[.='Invite your team members']")
    selenium.screenshot(mode+'-invite')
    selenium.click_by(By.XPATH, "//span[.='Finish setup']")
    selenium.invisible_by(By.XPATH, "//span[.='Invite your team members']")

    selenium.find_by(By.XPATH, "//span[contains(.,'Experience a better way')]")
    selenium.screenshot(mode+'-experience')
    #selenium.click_by(By.XPATH, "//span[contains(.,'Experience a better way')]/../../../..//span'")
    selenium.click_by(By.XPATH, "//button[@class='close']")
    selenium.invisible_by(By.XPATH, "//span[contains(.,'Experience a better way')]")
 
    selenium.find_by(By.XPATH, "//span[contains(.,'Welcome to Town Square')]")
    #selenium.screenshot(mode+'-welcome')
    #selenium.click_by(By.XPATH, "//button[@class='close']")
    #selenium.invisible_by(By.XPATH, "//span[.='Visible to Admins only']")
    #selenium.click_by(By.XPATH, "//span[contains(.,'No thanks')]")
    selenium.invisible_by(By.XPATH, "//span[contains(.,'No thanks')]")

    selenium.screenshot(mode+'-chat')


def post_message(mode, selenium):
    selenium.clickable_by(By.XPATH, "//textarea[@id='post_textbox']").send_keys("test message")
    selenium.click_by(By.XPATH, "//button[@data-testid='SendMessageButton']")
    selenium.screenshot(mode+'-post-message')

def check_message(mode, selenium):
    selenium.find_by(By.XPATH, "//div[@class='post-message__text' and .='test message']")
    selenium.screenshot(mode+'-check-message')
