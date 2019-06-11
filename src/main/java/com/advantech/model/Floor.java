package com.advantech.model;
// Generated 2017/4/7 下午 02:26:06 by Hibernate Tools 4.3.1

import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.voodoodyne.jackson.jsog.JSOGGenerator;
import java.util.HashSet;
import java.util.Set;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

/**
 * Floor generated by hbm2java
 */
@Entity
@Table(name = "[Floor]")
@JsonIdentityInfo(generator = JSOGGenerator.class)
public class Floor implements java.io.Serializable {

    private int id;
    private String name;

    @JsonIgnore
    private Set<User> users = new HashSet<>(0);

    @JsonIgnore
    private Set<StorageSpace> storageSpaces = new HashSet<>(0);

    @JsonIgnore
    private Set<Line> lines = new HashSet<>(0);

    @JsonIgnore
    private Set<LineSchedule> lineSchedules = new HashSet<>(0);

    public Floor() {
    }

    public Floor(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public Floor(int id, String name, Set<User> users) {
        this.id = id;
        this.name = name;
        this.users = users;
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", unique = true, nullable = false)
    public int getId() {
        return this.id;
    }

    public void setId(int id) {
        this.id = id;
    }

    @Column(name = "name", nullable = false, length = 50)
    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @JsonIgnore
    @JsonIgnoreProperties
    @OneToMany(fetch = FetchType.LAZY, mappedBy = "floor")
    public Set<User> getUsers() {
        return this.users;
    }

    public void setUsers(Set<User> users) {
        this.users = users;
    }

    @JsonIgnore
    @JsonIgnoreProperties
    @OneToMany(fetch = FetchType.LAZY, mappedBy = "floor")
    public Set<StorageSpace> getStorageSpaces() {
        return storageSpaces;
    }

    public void setStorageSpaces(Set<StorageSpace> storageSpaces) {
        this.storageSpaces = storageSpaces;
    }

    @JsonIgnore
    @JsonIgnoreProperties
    @OneToMany(fetch = FetchType.LAZY, mappedBy = "floor")
    public Set<Line> getLines() {
        return lines;
    }

    public void setLines(Set<Line> lines) {
        this.lines = lines;
    }

    @JsonIgnore
    @JsonIgnoreProperties
    @OneToMany(fetch = FetchType.LAZY, mappedBy = "floor")
    public Set<LineSchedule> getLineSchedules() {
        return lineSchedules;
    }

    public void setLineSchedules(Set<LineSchedule> lineSchedules) {
        this.lineSchedules = lineSchedules;
    }

}
