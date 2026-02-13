<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Elite Experience</title>
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
            <h1>Hello, World.</h1>
        </div>
        <div class="subtitle">The Next Generation</div>
        <div class="divider"></div>
    </div>

</body>
</html>