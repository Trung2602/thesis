package com.lht.jwt;

import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.JWSSigner;
import com.nimbusds.jose.JWSVerifier;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jose.crypto.MACVerifier;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import org.springframework.beans.factory.annotation.Value;

import java.util.Date;
import java.util.UUID;

public class JwtUtils {
    @Value("${jwt.secret}")
    private String secret;

    private final long EXPIRATION_MS = 86400000; // 1 ngày

    public String generateToken(String mail, String role, UUID uuid) throws Exception {
        JWSSigner signer = new MACSigner(secret);

        JWTClaimsSet claimsSet = new JWTClaimsSet.Builder()
                .subject(mail)
                .claim("role", role)
                .claim("uuid", uuid.toString())
                .expirationTime(new Date(System.currentTimeMillis() + EXPIRATION_MS))
                .issueTime(new Date())
                .build();

        SignedJWT signedJWT = new SignedJWT(
                new JWSHeader(JWSAlgorithm.HS256),
                claimsSet
        );

        signedJWT.sign(signer);

        return signedJWT.serialize();
    }

    public boolean validateToken(String token) throws Exception {
        SignedJWT signedJWT = SignedJWT.parse(token);
        JWSVerifier verifier = new MACVerifier(secret);

        if (signedJWT.verify(verifier)) {
            Date expiration = signedJWT.getJWTClaimsSet().getExpirationTime();
            return expiration.after(new Date());
        }
        return false;
    }

    public String getMail(String token) throws Exception {
        SignedJWT signedJWT = SignedJWT.parse(token);
        return signedJWT.getJWTClaimsSet().getSubject();
    }

    public String getRole(String token) throws Exception {
        SignedJWT signedJWT = SignedJWT.parse(token);
        return signedJWT.getJWTClaimsSet().getStringClaim("role");
    }

    public String getUuid(String token) throws Exception {
        SignedJWT signedJWT = SignedJWT.parse(token);
        return signedJWT.getJWTClaimsSet().getStringClaim("uuid");
    }
}
