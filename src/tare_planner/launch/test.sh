#!/bin/bash
# launch_tare_sim.sh: 启动 tare 仿真并在指定时间后关闭新开的 gnome-terminal

# 1) 定义参数
world_name="forest_160"
x=136.600000
y=21.000000
# z=1.5
max_time=6666

# 记录启动脚本前的所有 gnome-terminal 进程ID
PIDS_BEFORE=$(ps aux | grep "[g]nome-terminal" | awk '{print $2}')

# 2) 启动仿真
gnome-terminal --disable-factory -- bash -l -c "
  cd /home/zhengkr/autonomous_exploration_development_environment &&
  source devel/setup.bash &&
  roslaunch vehicle_simulator comp_exp.launch \
    world_name:=$world_name vehicleX:=$x vehicleY:=$y gazebo_gui:=false;
  exec bash" &
sleep 5

# 3) 启动规划
gnome-terminal --disable-factory -- bash -l -c "
  source devel/setup.bash &&
  roslaunch tare_planner comp_exp.launch \
    scenario:=$world_name rviz:=true;
  exec bash" &

sleep $((max_time + 10))
echo "Time is up! Killing all nodes..."

# 查找脚本期间新增的 gnome-terminal 并结束
PIDS_AFTER=$(ps aux | grep "[g]nome-terminal" | awk '{print $2}')
PIDS_TO_KILL=$(comm -13 <(echo "$PIDS_BEFORE" | sort) <(echo "$PIDS_AFTER" | sort))

[ -n "$PIDS_TO_KILL" ] && kill -2 $PIDS_TO_KILL 2>/dev/null && sleep 2
[ -n "$PIDS_TO_KILL" ] && kill -TERM $PIDS_TO_KILL 2>/dev/null && sleep 2
[ -n "$PIDS_TO_KILL" ] && kill -KILL $PIDS_TO_KILL 2>/dev/null

# 等待所有节点结束
sleep 30

