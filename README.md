# robot-cobweb
Robot Cobweb is a docker image built solution to be used for E2E web testing (desktop/mobile) with Robot Framework and Selenium Library. This image is built based on latest Ubuntu LTS 18.04, and lightweight Openbox window manager.

## Purposes
1. Run UI tests for web (desktop/mobile) with Robot Framework + Selenium Library in local machine

## What is inside this container?
1. [noVNC](https://github.com/novnc/noVNC) to see what happen inside docker container
2. [Openbox](http://openbox.org/wiki/Main_Page) desktop environment under Ubuntu LTS 18.04 OS
3. Browsers:
    - Mozilla Firefox + Geckodriver
    - Chromium + Chromedriver
4. [Robot Framework Library](https://github.com/robotframework/robotframework), including:
    - [SeleniumLibrary](https://github.com/robotframework/SeleniumLibrary)
    - [Faker Library](https://github.com/guykisel/robotframework-faker) for Robot Framework

## Requirements
[Docker](https://docs.docker.com/install/) is installed in your system.

## Quick Start
1. Run this image by using docker run command. You should mount your Robot Framework test script in your host machine to docker container path at ```/home/robot```. Let say your RF test script is located in ```/home/my_user/test_script_dir```

    ```
    docker run -d --name robotframework -p 6080:6080 -v /home/my_user/test_script_dir:/home/robot/test_script_dir semutmerah/robot-cobweb
    ```

2. Verify the ip address of docker host. For Linux OS, localhost should work.
3. Open http://localhost:6080 from web browser. Let this open during testing, so you can monitor what actually happen.
4. Run your RF test script. There's two way to execute robot command. One is from outside the container, and another one is from inside container.
    - Run robot command from inside the container:
        - Put yourself inside the container by exec command:

        ```
        docker exec -it robotframework bash
        ```

        - Change to user ```robot``` and go to your robot test script directory based on your mounting point before. Let say, it located at ```/home/robot/test_script_dir```

        ```
        su robot
        cd /home/robot/test_script_dir
        ```

        - execute the robot command

        ```
        robot tests/test_script.robot
        ```

    - Run robot command from outside the container:
        - Let say, your robot test script is located at ```/home/robot/test_script_dir/tests/test.robot``` inside the container:
        
        ```
        docker exec -u robot -w /home/robot robotframework robot /home/robot/test_script_dir/tests/test.robot
        ```
    
    While the test running, you can see from [noVNC](http://localhost:6080) that the web browser (based on your RF script configuration) will opened and run the test script.
