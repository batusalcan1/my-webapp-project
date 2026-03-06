<<<<<<< HEAD
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>TODO App</title>
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
      rel="stylesheet"
    />
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"
      rel="stylesheet"
    />
    <style>
      body {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
      }
      .glass {
        background: rgba(255, 255, 255, 0.15);
        backdrop-filter: blur(10px);
        border-radius: 15px;
        padding: 2rem;
        box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
        max-width: 600px;
        width: 100%;
        color: white;
      }
      h1 {
        text-align: center;
        margin-bottom: 2rem;
        font-size: 2.5rem;
        font-weight: 700;
      }
      .input-group {
        margin-bottom: 1.5rem;
      }
      .input-group input {
        background: rgba(255, 255, 255, 0.2);
        border: 1px solid rgba(255, 255, 255, 0.3);
        color: white;
        padding: 12px 16px;
      }
      .input-group input::placeholder {
        color: rgba(255, 255, 255, 0.7);
      }
      .input-group input:focus {
        background: rgba(255, 255, 255, 0.25);
        border-color: rgba(255, 255, 255, 0.5);
        outline: none;
        box-shadow: 0 0 15px rgba(102, 126, 234, 0.3);
      }
      .btn-add {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border: 1px solid rgba(255, 255, 255, 0.3);
        color: white;
        font-weight: 600;
      }
      .btn-add:hover {
        background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        color: white;
      }
      .task-list {
        max-height: 500px;
        overflow-y: auto;
      }
      .task-item {
        background: rgba(255, 255, 255, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
        border-radius: 10px;
        padding: 15px;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 12px;
      }
      .task-item:hover {
        background: rgba(255, 255, 255, 0.15);
      }
      .task-item.completed .task-title {
        text-decoration: line-through;
        opacity: 0.6;
      }
      .task-checkbox {
        width: 20px;
        height: 20px;
        cursor: pointer;
      }
      .task-title {
        flex-grow: 1;
      }
      .btn-icon {
        background: rgba(255, 255, 255, 0.2);
        border: none;
        color: white;
        width: 36px;
        height: 36px;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        font-size: 0.9rem;
      }
      .btn-icon:hover {
        background: rgba(255, 255, 255, 0.3);
      }
      .btn-icon.delete:hover {
        background: rgba(244, 67, 54, 0.6);
      }
      .btn-icon.edit:hover {
        background: rgba(33, 150, 243, 0.6);
      }
      .empty-state {
        text-align: center;
        padding: 40px 20px;
        opacity: 0.8;
      }
    </style>
  </head>
  <body>
    <div class="glass">
      <h1><i class="bi bi-check-circle"></i> My Tasks</h1>
      <div class="input-group">
        <input
          id="newTask"
          type="text"
          class="form-control"
          placeholder="Add a new task..."
        />
        <button id="addBtn" class="btn btn-add">Add</button>
      </div>
      <div id="taskList" class="task-list"></div>
      <div id="emptyState" class="empty-state" style="display: none">
        <p><i class="bi bi-inbox"></i> No tasks yet</p>
      </div>
    </div>

    <script>
      // compute context path so URLs work regardless of deployment context
      const ctx = "<%= request.getContextPath() %>";
      // avoid template literals inside JSP, use normal concatenation
      const baseUrl = ctx + "/api/tasks";

      async function loadTasks() {
        try {
          const resp = await fetch(baseUrl);
          const tasks = await resp.json();
          renderTasks(tasks);
        } catch (e) {
          console.error("Failed to load tasks", e);
        }
      }

      function renderTasks(tasks) {
        const list = document.getElementById("taskList");
        const empty = document.getElementById("emptyState");
        list.innerHTML = "";

        if (tasks.length === 0) {
          empty.style.display = "block";
          return;
        }
        empty.style.display = "none";

        tasks.forEach((task) => {
          const li = document.createElement("div");
          li.className = "task-item" + (task.completed ? " completed" : "");

          const checkbox = document.createElement("input");
          checkbox.type = "checkbox";
          checkbox.className = "task-checkbox";
          checkbox.checked = task.completed;
          checkbox.addEventListener("change", () =>
            toggleCompleted(task, checkbox.checked),
          );

          const titleSpan = document.createElement("span");
          titleSpan.className = "task-title";
          titleSpan.textContent = task.title;

          const editBtn = document.createElement("button");
          editBtn.className = "btn-icon edit";
          editBtn.innerHTML = '<i class="bi bi-pencil-fill"></i>';
          editBtn.addEventListener("click", () => startEdit(task, titleSpan));

          const deleteBtn = document.createElement("button");
          deleteBtn.className = "btn-icon delete";
          deleteBtn.innerHTML = '<i class="bi bi-trash-fill"></i>';
          deleteBtn.addEventListener("click", () => deleteTask(task.id, li));

          li.appendChild(checkbox);
          li.appendChild(titleSpan);
          li.appendChild(editBtn);
          li.appendChild(deleteBtn);
          list.appendChild(li);
        });
      }

      document.getElementById("addBtn").addEventListener("click", async () => {
        const input = document.getElementById("newTask");
        const title = input.value.trim();
        if (!title) return;
        try {
          const resp = await fetch(baseUrl, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ title }),
          });
          loadTasks();
          input.value = "";
        } catch (e) {
          console.error("Failed to add task", e);
        }
      });

      document.getElementById("newTask").addEventListener("keypress", (e) => {
        if (e.key === "Enter") document.getElementById("addBtn").click();
      });

      async function toggleCompleted(task, completed) {
        try {
          await fetch(baseUrl + "/" + task.id, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ id: task.id, title: task.title, completed }),
          });
          loadTasks();
        } catch (e) {
          console.error("Failed to update task", e);
        }
      }

      function startEdit(task, titleSpan) {
        const newTitle = prompt("Edit task:", task.title);
        if (newTitle !== null && newTitle.trim()) {
          updateTask(task.id, newTitle.trim(), task.completed);
        }
      }

      async function updateTask(id, title, completed) {
        try {
          await fetch(baseUrl + "/" + id, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ id, title, completed }),
          });
          loadTasks();
        } catch (e) {
          console.error("Failed to save edit", e);
        }
      }

      async function deleteTask(id, element) {
        try {
          await fetch(baseUrl + "/" + id, { method: "DELETE" });
          element.remove();
        } catch (e) {
          console.error("Failed to delete task", e);
        }
      }

      loadTasks();
    </script>
  </body>
</html>
=======
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My WebApp Project</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;600;800&display=swap');

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;

            background: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
            overflow: hidden;
            color: #fff;
        }

        .orb {
            position: absolute;
            width: 400px;
            height: 400px;
            background: radial-gradient(circle, rgba(0,212,255,0.2) 0%, rgba(0,0,0,0) 70%);
            border-radius: 50%;
            z-index: 1;
            animation: float 10s infinite alternate ease-in-out;
        }

        @keyframes float {
            from { transform: translate(-20%, -20%); }
            to { transform: translate(20%, 20%); }
        }

        .glass-card {
            position: relative;
            z-index: 10;
            padding: 3rem 5rem;
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 24px;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
            text-align: center;
            transition: transform 0.3s ease;
        }

        .glass-card:hover {
            transform: translateY(-10px);
        }

        .title-wrapper {
            overflow: hidden;
        }

        h1 {
            font-size: 4rem;
            font-weight: 800;
            letter-spacing: -1px;
            background: linear-gradient(to right, #fff, #a5a5a5);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 0.5rem;
            text-transform: uppercase;
        }

        .subtitle {
            font-weight: 300;
            font-size: 1.1rem;
            letter-spacing: 5px;
            color: rgba(255, 255, 255, 0.6);
            text-transform: uppercase;
        }


        .divider {
            height: 2px;
            width: 50px;
            background: #00d4ff;
            margin: 1.5rem auto;
            border-radius: 2px;
        }

        .timestamp {
            font-size: 0.8rem;
            color: rgba(255, 255, 255, 0.4);
            font-family: monospace;
        }
    </style>
</head>
<body>

    <div class="orb"></div>

    <div class="glass-card">
        <div class="title-wrapper">
            <h1>Welcome to My WebApp</h1>
        </div>
        <div class="subtitle">The Next Generation</div>
        <div class="divider"></div>
    </div>

</body>
</html>
>>>>>>> 42e99f9e9535dc14844b592498174539fcd9b6eb
