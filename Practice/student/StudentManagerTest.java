package student;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.junit.jupiter.api.MethodOrderer.OrderAnnotation;
import static org.junit.jupiter.api.Assertions.*;

@TestMethodOrder(OrderAnnotation.class)
class StudentManagerTest {
    private static StudentManager manager;

    @BeforeAll
    static void setUp() {
        manager = new StudentManager();
    }

    @Test
    @Order(1)
    void testAddAndRemoveStudent() {
        manager.addStudent("김지민");

        assertTrue(manager.hasStudent("김지민"), "학생이 정상적으로 추가되어야 합니다.");
    
        manager.removeStudent("김지민");

        assertFalse(manager.hasStudent("김지민"), "학생이 정상적으로 제거되어야 합니다.");
    }

    @Test
    @Order(2)
    void testDuplicateAddThrowsException() {
        manager.addStudent("김철수");

        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> manager.addStudent("김철수"),
                "중복 추가 시 IllegalArgumentException이 발생해야 합니다."
        );

        assertTrue(exception.getMessage().contains("이미 존재하는 학생"),
                "예외 메시지에 '이미 존재하는 학생'이 포함되어야 합니다.");
    }

    @Test
    @Order(3)
    void testRemoveNonExistentThrowsException() {
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> manager.removeStudent("박무식"),
                "존재하지 않는 학생 제거 시 IllegalArgumentException이 발생해야 합니다."
        );

        assertTrue(exception.getMessage().contains("존재하지 않는 학생"),
                "예외 메시지에 '존재하지 않는 학생'이 포함되어야 합니다.");
    }
}
