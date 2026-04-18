package com.lht.pojo;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "admin")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
@PrimaryKeyJoinColumn(name = "account_uuid")
public class Admin extends Account {

    @Column(columnDefinition = "text")
    private String permissions;
}