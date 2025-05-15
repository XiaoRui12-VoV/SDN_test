#!/bin/bash

echo "📁 初始化 OVS 所需目录..."
mkdir -p /var/run/openvswitch
mkdir -p /etc/openvswitch
mkdir -p /var/lib/openvswitch

# 🧠 创建配置数据库（首次启动才需要）
if [ ! -f /etc/openvswitch/conf.db ]; then
    echo "🛠️ 创建 OVS 配置数据库..."
    ovsdb-tool create /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema
fi

echo "🚀 启动 ovsdb-server..."
ovsdb-server --remote=punix:/var/run/openvswitch/db.sock \
             --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
             --pidfile --detach

echo "🔧 初始化 OVS 控制器..."
ovs-vsctl --no-wait init

echo "⚙️ 启动 ovs-vswitchd..."
ovs-vswitchd --pidfile --detach

# ⌛ 等待 faucet 控制器上线
echo "⏳ 等待 faucet 控制器上线..."
for i in {1..10}; do
    ping -c 1 faucet >/dev/null 2>&1 && echo "✅ faucet 可达！" && break
    echo "等待中 ($i)..."
    sleep 1
done

# 🧪 启动实验拓扑（不指定 dpid，避免类型错误）
echo "🌐 启动 Mininet 拓扑..."
mn --controller=remote,ip=faucet,port=6653 --topo single,2 --mac --switch ovsk --test pingall

# 🧰 保持容器运行
echo "🧰 容器启动完毕，进入 bash 模式等待进一步操作..."
bash
