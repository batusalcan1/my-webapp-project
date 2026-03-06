package com.example.servlet;

import com.example.dao.TaskDAO;
import com.example.model.Task;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.List;

@WebServlet("/api/tasks/*")
public class TasksServlet extends HttpServlet {
    private final TaskDAO dao = TaskDAO.getInstance();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Task> tasks = dao.getAllTasks();
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(tasks));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        BufferedReader reader = req.getReader();
        Task incoming = gson.fromJson(reader, Task.class);
        Task created = dao.addTask(incoming);
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(created));
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo(); // /{id}
        if (path == null || path.length() <= 1) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        int id = Integer.parseInt(path.substring(1));
        boolean ok = dao.deleteTask(id);
        resp.setStatus(ok ? HttpServletResponse.SC_NO_CONTENT : HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("[DEBUG] doPut called");
        System.out.println("[DEBUG] Request path: " + req.getRequestURI());
        System.out.println("[DEBUG] Request pathInfo: " + req.getPathInfo());

        // extract id from URL (/api/tasks/{id})
        String path = req.getPathInfo();
        int pathId = -1;
        if (path != null && path.length() > 1) {
            try {
                pathId = Integer.parseInt(path.substring(1));
            } catch (NumberFormatException e) {
                System.out.println("[DEBUG] Invalid id in path: " + path);
            }
        }
        System.out.println("[DEBUG] Parsed path id: " + pathId);

        BufferedReader reader = req.getReader();
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        String body = sb.toString();
        System.out.println("[DEBUG] Request body: " + body);

        Task incoming = gson.fromJson(body, Task.class);
        // if JSON didn't include an id, use the path id
        if ((incoming.getId() == 0 || incoming.getId() == -1) && pathId != -1) {
            incoming.setId(pathId);
        }
        System.out.println("[DEBUG] Parsed task - id: " + incoming.getId() + ", title: " + incoming.getTitle() + ", completed: " + incoming.isCompleted());

        boolean ok = dao.updateTask(incoming);
        System.out.println("[DEBUG] Update result: " + ok);

        resp.setStatus(ok ? HttpServletResponse.SC_NO_CONTENT : HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("[DEBUG] doOptions called for: " + req.getRequestURI());
        
        resp.setHeader("Allow", "GET, POST, PUT, DELETE, OPTIONS");
        resp.setHeader("Access-Control-Allow-Origin", "*");
        resp.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        resp.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        resp.setHeader("Access-Control-Max-Age", "3600");
        
        resp.setStatus(HttpServletResponse.SC_OK);
    }
}
