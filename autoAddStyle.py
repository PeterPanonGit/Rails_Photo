from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
import os
import pandas as pd

#options = webdriver.ChromeOptions()
#options.add_experimental_option("excludeSwitches", ["ignore-certificate-errors"])
#driver = webdriver.Chrome(os.environ["HOME"] + "/Downloads/chromedriver", chrome_options=options)
driver = webdriver.Firefox()
base_url = os.environ["BASE_URL"]
driver.get(base_url + "/clients/sign_in")

driver.find_element_by_id("client_email").clear()
driver.find_element_by_id("client_email").send_keys(os.environ["ADMIN_EMAIL"])
driver.find_element_by_id("client_password").clear()
driver.find_element_by_id("client_password").send_keys(os.environ["ADMIN_PWD"])
driver.find_element_by_name("commit").click()    

element = WebDriverWait(driver, 10).until(EC.visibility_of_element_located((By.LINK_TEXT,'Admin')))

style_path = os.environ["HOME"] + "/Pictures/styles/selected-scaled/"

styles = pd.read_csv("styles.csv")
for index, row in styles.iterrows():
  driver.get(base_url + "/styles/new")
  driver.find_element_by_id("style_image").clear()
  driver.find_element_by_id("style_image").send_keys(style_path + row["style_file"])
  driver.find_element_by_id("style_init").clear()
  driver.find_element_by_id("style_init").send_keys(row["name"])
  driver.find_element_by_id("style_tag_list").clear()
  driver.find_element_by_id("style_tag_list").send_keys(row["tags"].replace(";", ","))
  driver.find_element_by_name("commit").click()
  element = WebDriverWait(driver, 20).until(EC.visibility_of_element_located((By.CLASS_NAME,'successMessage')))
