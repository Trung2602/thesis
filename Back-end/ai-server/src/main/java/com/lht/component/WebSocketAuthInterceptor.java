package com.lht.component;

import com.lht.pojo.UserPrincipal;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

@Component
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            String authHeader = accessor.getFirstNativeHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                try {
                    if (JwtUtils.validateToken(token)) {
                        String mail = JwtUtils.getMail(token);
                        String role = JwtUtils.getRole(token);
                        String uuidStr = JwtUtils.getUuid(token);
                        UUID uuid = UUID.fromString(uuidStr);
                        UserPrincipal userPrincipal = new UserPrincipal(uuid, mail);
                        UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(
                                    userPrincipal, token, List.of(new SimpleGrantedAuthority("ROLE_" + role))
                            );
                        accessor.setUser(authentication);
                    }
                } catch (Exception e) {
                    System.out.println("WS JWT error: " + e.getMessage());
                }
            }
        }
        return message;
    }
}
