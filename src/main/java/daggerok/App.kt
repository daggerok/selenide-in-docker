package daggerok

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.method.configuration.EnableReactiveMethodSecurity
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity
import org.springframework.security.core.userdetails.MapReactiveUserDetailsService
import org.springframework.security.core.userdetails.User
import org.springframework.security.crypto.factory.PasswordEncoderFactories
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.*
import org.springframework.web.reactive.result.view.Rendering
import java.util.*

@ControllerAdvice
class ModelAdvice {
  @ModelAttribute("pseudoStatefulModel")
  fun pseudoStatefulModel() = mutableMapOf("message" to "ololo trololo")
}

fun MutableMap<String, Any>.greet(payload: String): MutableMap<String, Any> {
  this["message"] = "Hello, ${payload.capitalize()}!"
  return this
}

@Controller
class IndexPage {

  @GetMapping(path = ["", "/"])
  fun index(@RequestParam(required = false, name = "name") name: Optional<String>,
            @ModelAttribute("pseudoStatefulModel") pseudoStatefulModel: MutableMap<String, Any>) =
      Rendering.view("index")
          .model(pseudoStatefulModel.greet(name.orElse("my friend")))
          .build()

  @GetMapping("/{name}")
  fun path(@PathVariable("name") name: String,
           @ModelAttribute("pseudoStatefulModel") pseudoStatefulModel: MutableMap<String, Any>) =
      Rendering.view("index")
          .model(pseudoStatefulModel.greet(name))
          .build()
}

@Configuration
@EnableWebFluxSecurity
//@EnableReactiveMethodSecurity //useless here
class SecurityConfig {

  @Bean fun encoder() = PasswordEncoderFactories.createDelegatingPasswordEncoder()!!

  @Bean
  fun reactiveUserDetailsService(encoder: PasswordEncoder): MapReactiveUserDetailsService {

    val users = mapOf(
        "user1" to mapOf(
            "username" to "maksimko",
            "password" to "passwordinko"
        )
    )

    return MapReactiveUserDetailsService(*users
        .values
        .map {
          User.withUsername(it["username"])
              .password(encoder.encode(it["password"]))
              .authorities("USER")
              .build()
        }
        .toTypedArray()
    )
  }
}

@SpringBootApplication
class App

fun main(args: Array<String>) {
  runApplication<App>(*args)
}
