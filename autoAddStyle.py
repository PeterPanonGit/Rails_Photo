from selenium import webdriver
import os
import pandas as pd

options = webdriver.ChromeOptions()
options.add_experimental_option("excludeSwitches", ["ignore-certificate-errors"])
driver = webdriver.Chrome(os.environ["HOME"] + "/Downloads/chromedriver", chrome_options=options)
base_url = os.environ["BASE_URL"]
driver.get(base_url + "/clients/sign_in")

driver.find_element_by_id("client_email").clear()
driver.find_element_by_id("client_email").send_keys(os.environ["ADMIN_EMAIL"])
driver.find_element_by_id("client_password").clear()
driver.find_element_by_id("client_password").send_keys(os.environ["ADMIN_PWD"])
driver.find_element_by_name("commit").click()    


style_path = os.environ["HOME"] + "/Pictures/styles/selected-scaled/"

styles = pd.read_csv("styles.csv")
for index, row in styles.iterrows():
  driver.get(base_url + "/styles/new")
  driver.find_element_by_id("style_image").clear()
  driver.find_element_by_id("style_image").send_keys(style_path + row["style_file"])
  driver.find_element_by_id("style_init").clear()
  driver.find_element_by_id("style_init").send_keys(row["name"])
  driver.find_element_by_name("commit").click()
