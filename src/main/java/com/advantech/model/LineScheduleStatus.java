package com.advantech.model;
// Generated 2017/4/7 下午 02:26:06 by Hibernate Tools 4.3.1

import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonIgnore;
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
 * UserType generated by hbm2java
 */
@Entity
@Table(name = "LineSchedule_Status")
@JsonIdentityInfo(generator = JSOGGenerator.class)
public class LineScheduleStatus implements java.io.Serializable {

    private int id;
    private String name;
    
    @JsonIgnore
    private Set<LineSchedule> lineSchedules = new HashSet<>(0);

    public LineScheduleStatus() {
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

    @OneToMany(fetch = FetchType.LAZY, mappedBy = "lineScheduleStatus")
    public Set<LineSchedule> getLineSchedules() {
        return lineSchedules;
    }

    public void setLineSchedules(Set<LineSchedule> lineSchedules) {
        this.lineSchedules = lineSchedules;
    }

    
}
