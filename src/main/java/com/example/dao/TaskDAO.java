package com.example.dao;

import com.example.model.Task;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TaskDAO {
    private static final String URL = "jdbc:sqlite:todo.db";
    private static TaskDAO instance;

    private TaskDAO() {
        initDatabase();
    }

    public static synchronized TaskDAO getInstance() {
        if (instance == null) {
            instance = new TaskDAO();
        }
        return instance;
    }

    private void initDatabase() {
        try {
            // ensure the SQLite driver is registered with DriverManager
            Class.forName("org.sqlite.JDBC");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("SQLite JDBC driver not found", e);
        }
        try (Connection conn = DriverManager.getConnection(URL);
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS tasks (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                    "title TEXT NOT NULL, " +
                    "completed BOOLEAN NOT NULL CHECK (completed IN (0,1))" +
                    ");");
        } catch (SQLException e) {
            throw new RuntimeException("Failed to initialize database", e);
        }
    }

    public List<Task> getAllTasks() {
        List<Task> list = new ArrayList<>();
        String sql = "SELECT id, title, completed FROM tasks";
        try (Connection conn = DriverManager.getConnection(URL);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Task t = new Task(
                        rs.getInt("id"),
                        rs.getString("title"),
                        rs.getBoolean("completed")
                );
                list.add(t);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    public Task addTask(Task task) {
        String sql = "INSERT INTO tasks(title, completed) VALUES(?, ?)";
        try (Connection conn = DriverManager.getConnection(URL);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, task.getTitle());
            ps.setBoolean(2, task.isCompleted());
            ps.executeUpdate();
            // SQLite JDBC doesn't support getGeneratedKeys; fall back to last_insert_rowid()
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT last_insert_rowid()")) {
                if (rs.next()) {
                    task.setId(rs.getInt(1));
                }
            }
            return task;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public boolean deleteTask(int id) {
        String sql = "DELETE FROM tasks WHERE id = ?";
        try (Connection conn = DriverManager.getConnection(URL);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public boolean updateTask(Task task) {
        System.out.println("[DAO DEBUG] updateTask called with task - id: " + task.getId() + ", title: " + task.getTitle() + ", completed: " + task.isCompleted());
        String sql = "UPDATE tasks SET title = ?, completed = ? WHERE id = ?";
        System.out.println("[DAO DEBUG] updateTask called with task - id: " + task.getId() + ", title: " + task.getTitle() + ", completed: " + task.isCompleted());
        System.out.println("[DAO DEBUG] SQL: " + sql);
        
        try (Connection conn = DriverManager.getConnection(URL);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, task.getTitle());
            ps.setBoolean(2, task.isCompleted());
            ps.setInt(3, task.getId());
            
            System.out.println("[DAO DEBUG] Executing update for id=" + task.getId());
            int rowsAffected = ps.executeUpdate();
            System.out.println("[DAO DEBUG] Rows affected: " + rowsAffected);
            
            // Verify the update
            String verifySql = "SELECT * FROM tasks WHERE id = ?";
            try (PreparedStatement verifyPs = conn.prepareStatement(verifySql)) {
                verifyPs.setInt(1, task.getId());
                ResultSet rs = verifyPs.executeQuery();
                if (rs.next()) {
                    System.out.println("[DAO DEBUG] After update - id: " + rs.getInt("id") + ", title: " + rs.getString("title") + ", completed: " + rs.getBoolean("completed"));
                } else {
                    System.out.println("[DAO DEBUG] Task with id=" + task.getId() + " not found in database!");
                }
            }
            
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("[DAO DEBUG] SQLException: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }
}
