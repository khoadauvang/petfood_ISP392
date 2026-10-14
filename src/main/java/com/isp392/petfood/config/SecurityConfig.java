package com.isp392.petfood.config;


import com.isp392.petfood.security.RoleBasedLoginSuccessHandler;
import jakarta.servlet.DispatcherType;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

//Bộ Luật
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final RoleBasedLoginSuccessHandler loginSuccessHandler;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
            //auth là OBJECT cấu hình các Authorization Rules do Spring truyền vào lambda
            .authorizeHttpRequests(auth -> auth
                // (1) Luot forward nội bộ toi file JSP va trang loi
                .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()
                // (2) Tai nguyen tinh
                .requestMatchers("/css/**", "/js/**", "/images/**", "/favicon.ico", "/error").permitAll()
                // (3) Guest: xem san pham, dang ky, dang nhap (BR-07)
                .requestMatchers("/", "/login", "/register", "/products/**").permitAll()
                // (4) Theo vai tro
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .requestMatchers("/staff/**").hasAnyRole("STAFF", "ADMIN")
                .requestMatchers("/cart/**", "/checkout/**", "/orders/**", "/profile/**").hasRole("CUSTOMER")
                // (5) Còn lại: chỉ cần đã đăng nhập
                .anyRequest().authenticated()
                //với những req chưa khớp bất kỳ quy tắc nào phía trên, ycầu ng dùng phải login.
            )
            .formLogin(form -> form
                .loginPage("/login")            //GET la trang cua minh, POST do Spring xu ly
                .usernameParameter("email")       //mac dinh Spring doc field "username"
                .successHandler(loginSuccessHandler)
                .failureUrl("/login?error")
                .permitAll()
            )
            .logout(logout -> logout
                .logoutSuccessUrl("/login?logout")
                .permitAll()
            )
            .exceptionHandling(ex -> ex.accessDeniedPage("/403"));
        return http.build();
    }
}
