package com.isp392.petfood.config;


import com.isp392.petfood.security.GoogleAccountService;
import com.isp392.petfood.security.RoleBasedLoginSuccessHandler;
import jakarta.servlet.DispatcherType;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.client.oidc.userinfo.OidcUserService;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.web.SecurityFilterChain;

//Bộ Luật
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final RoleBasedLoginSuccessHandler loginSuccessHandler;
    private final GoogleAccountService googleAccountService;
    // Chỉ có bean này khi file .env khai báo client-id/secret của Google (xem application.properties)
    private final ObjectProvider<ClientRegistrationRepository> clientRegistrations;

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
                // (3) Guest: xem san pham, dang ky, dang nhap (ca Google) (BR-07)
                .requestMatchers("/", "/login", "/register", "/products/**", "/flash-sale",
                        "/oauth2/**", "/login/oauth2/**").permitAll()
                // VNPay gọi về: không có phiên đăng nhập, chỉ tin dữ liệu có chữ ký đúng (BR-24)
                .requestMatchers("/payment/vnpay-return", "/payment/vnpay-ipn").permitAll()
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

        // Đăng nhập Google (tùy chọn, chỉ cho khách - BR-05). Nút bắt đầu ở /oauth2/authorization/google.
        // Google trả về OidcUser (scope có "openid") hoặc OAuth2User (không có "openid"); cả hai đều được đổi thành
        // AccountPrincipal để phần còn lại của app không cần biết khách đăng nhập bằng cách nào.
        if (clientRegistrations.getIfAvailable() != null) {
            OidcUserService oidcUserService = new OidcUserService();
            DefaultOAuth2UserService oauth2UserService = new DefaultOAuth2UserService();
            http.oauth2Login(oauth -> oauth
                .loginPage("/login")
                .userInfoEndpoint(info -> info
                    .oidcUserService(request -> googleAccountService.loadOrRegister(oidcUserService.loadUser(request)))
                    .userService(request -> googleAccountService.loadOrRegister(oauth2UserService.loadUser(request))))
                .successHandler(loginSuccessHandler)
                // SimpleUrlAuthenticationFailureHandler lưu lỗi vào session (SPRING_SECURITY_LAST_EXCEPTION)
                // để login.jsp hiện đúng lý do (ví dụ tài khoản nhân viên dùng Google)
                .failureUrl("/login?googleError")
            );
        }
        return http.build();
    }
}
