package daggerok

import com.codeborne.selenide.Condition.*
import com.codeborne.selenide.Selenide.*
import com.codeborne.selenide.WebDriverRunner
import org.junit.Rule
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.openqa.selenium.chrome.ChromeOptions
import org.openqa.selenium.remote.DesiredCapabilities
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment.RANDOM_PORT
import org.springframework.boot.web.server.LocalServerPort
import org.springframework.test.context.junit.jupiter.SpringExtension
import org.testcontainers.containers.BrowserWebDriverContainer
import org.testcontainers.containers.BrowserWebDriverContainer.VncRecordingMode.RECORD_ALL
import java.io.File

class KGenericContainer() : BrowserWebDriverContainer<KGenericContainer>()

@ExtendWith(SpringExtension::class)
@SpringBootTest(webEnvironment = RANDOM_PORT)
class `What can I say? Kotlin is awesome!`(@LocalServerPort val port: Int) {

  private fun String.slowPoke() {
    println("""
      |---
      |${`$`(this).text()}
      """.trimMargin())
    sleep(1000)
  }

/*
  @Rule
  val chrome: KGenericContainer = KGenericContainer()
      .withDesiredCapabilities(DesiredCapabilities.chrome())
      .withRecordingMode(RECORD_ALL, File("build"))

  @BeforeEach
  fun setUp() {
    val driver = chrome.webDriver
    WebDriverRunner.setWebDriver(driver)
  }

  @AfterEach
  fun tearDown() {
    WebDriverRunner.closeWebDriver()
  }
*/

  @Test
  fun `test everything in single success flow`() {

    // unauthorized user mast be redirected to login page,
    // so sign in with credentials maksimko / passwordinko
    open("http://127.0.0.1:$port")
    "body".slowPoke()
    val form = `$`(".form-signin")
    form.find("#username").value = "maksimko"
    form.find("#password").value = "passwordinko"
    form.find("button[type=submit]").click()

    // assert default greeting message
    open("http://127.0.0.1:$port/")

    "body".slowPoke()
    `$`("body").shouldHave(text("Hello, My friend!"))

    // verify name from query params
    open("http://127.0.0.1:$port/?name=selenidko")

    "body".slowPoke()
    `$`("span").shouldHave(exactText("Hello, Selenidko!"))

    // and lastly verify greeting according to name from path
    open("http://127.0.0.1:$port/lol")

    "body".slowPoke()
    `$`("body > span").shouldHave(exactText("Hello, Lol!"))

    // go to /logout, click on button, verify sign out success
    open("http://127.0.0.1:$port/logout")

    "body".slowPoke()
    `$`("form.form-signin")
        .should(exist)
        .should(appears)
        .shouldHave(text("Are you sure you want to log out?"))
        .shouldHave(text("Log Out"))
        .find("button[type='submit']")
        .click()

    "body".slowPoke()
    `$`("div.alert.alert-success")
        .should(exist)
        .should(appear)
        .shouldHave(text("You have been signed ou"))
  }
}
