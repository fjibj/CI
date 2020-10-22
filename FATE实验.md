FATE实验


单机部署 http://172.32.150.132:8080/

参考： FATE/Fate-standalone_deployment_guide_zh.md at master · FederatedAI/FATE

https://github.com/FederatedAI/FATE/blob/master/standalone-deploy/doc/Fate-standalone_deployment_guide_zh.md

集群部署

172.32.150.133 VM_0_1_centos

172.32.150.134 VM_0_2_centos

172.32.150.135 VM_0_3_centos

/mnt/disk01/fangjin/projects/fate

参考：FATE/Fate_step_by_step_install_zh.md at v1.4.5 · FederatedAI/FATE

https://github.com/FederatedAI/FATE/blob/v1.4.5/cluster-deploy/doc/Fate_step_by_step_install_zh.md

新建app用户和apps组：app/app123.

mysql密码：fate_dev

运行案例：

	source /mnt/disk01/fangjin/projects/fate/init_env.sh
  
	source /mnt/disk01/fangjin/projects/fate/common/python/venv/bin/activate
  
	cd /mnt/disk01/fangjin/projects/fate/python/examples/federatedml-1.x-examples/hetero_secureboost
  
	vim test_secureboost_train_binary_conf.json 

"job_parameters": {
        "work_mode": 1   （0单边，1集群）
    },
    "role": {
        "guest": [
            10000
        ],
        "host": [
            9999
        ]
    },

1. 加载数据

	pip install arch
  
在GUEST（133）上运行：

python /mnt/disk01/fangjin/projects/fate/python/fate_flow/fate_flow_client.py -f upload -c upload_data_guest.json

在HOST（135）上运行：

 python /mnt/disk01/fangjin/projects/fate/python/fate_flow/fate_flow_client.py -f upload -c upload_data_host.json	

   2. 训练
   
python /mnt/disk01/fangjin/projects/fate/python/fate_flow/fate_flow_client.py -f submit_job -c test_secureboost_train_binary_conf.json -d test_secureboost_train_dsl.json （坑，work_mode居然不能通过-w参数来设置）

输出：

{
    "data": {
        "board_url": "http://172.32.150.133:8080/index.html#/dashboard?job_id=2020102210205753613442&role=guest&party_id=10000",
        "job_dsl_path": "/mnt/disk01/fangjin/projects/fate/python/jobs/2020102210205753613442/job_dsl.json",
        "job_runtime_conf_path": "/mnt/disk01/fangjin/projects/fate/python/jobs/2020102210205753613442/job_runtime_conf.json",
        "logs_directory": "/mnt/disk01/fangjin/projects/fate/python/logs/2020102210205753613442",
        "model_info": {
            "model_id": "guest-10000#host-9999#model",
            "model_version": "2020102210205753613442"
        }
    },
    "jobId": "2020102210205753613442",
    "retcode": 0,
    "retmsg": "success"
}


      3.  推理

vim test_predict_conf.json

"job_parameters": {
        "work_mode": 1,
        "job_type": "predict",
        "model_id": "guest-10000#host-9999#model",  （从训练结果获得）
        "model_version": "2020102210205753613442"	   （从训练结果获得）
    },
    "role": {
        "guest": [
            10000
        ],
        "host": [
            9999
        ]
    },


python /mnt/disk01/fangjin/projects/fate/python/fate_flow/fate_flow_client.py -f submit_job -c test_predict_conf.json

输出：

{
    "data": {
        "board_url": "http://172.32.150.133:8080/index.html#/dashboard?job_id=2020102210495595874943&role=guest&party_id=10000",
        "job_dsl_path": "/mnt/disk01/fangjin/projects/fate/python/jobs/2020102210495595874943/job_dsl.json",
        "job_runtime_conf_path": "/mnt/disk01/fangjin/projects/fate/python/jobs/2020102210495595874943/job_runtime_conf.json",
        "logs_directory": "/mnt/disk01/fangjin/projects/fate/python/logs/2020102210495595874943",
        "model_info": {
            "model_id": "guest-10000#host-9999#model",
            "model_version": "2020102210205753613442"
        }
    },
    "jobId": "2020102210495595874943",
    "retcode": 0,
    "retmsg": "success"
}


4. 查询JOB状态

可以从 http://172.32.150.133:9090/#/history 查看

也可以：

python /mnt/disk01/fangjin/projects/fate/python/fate_flow/fate_flow_client.py -f query_job -j 2020102210495595874943 -r guest

5. 下载推理结果

python /mnt/disk01/fangjin/projects/fate/python/fate_flow/fate_flow_client.py -f component_output_data -j 2020102210495595874943 -p 10000 -r guest -cpn secureboost_0 -o ./results

输出：

{
    "retcode": 0,
    "directory": "/mnt/disk01/fangjin/projects/fate/python/examples/federatedml-1.x-examples/hetero_secureboost/results/job_20201022104955958
74943_secureboost_0_guest_10000_output_data",    "retmsg": "download successfully, please check /mnt/disk01/fangjin/projects/fate/python/examples/federatedml-1.x-examples/hetero_securebo
ost/results/job_2020102210495595874943_secureboost_0_guest_10000_output_data directory"}


6. 修改同态加密算法

修改运行时配置，如test_secureboost_train_binary_conf.json，将 

"algorithm_parameters": {
        "secureboost_0": {
            ...,
            "encrypt_param": {
                "method": "paillier"   改成 IterativeAffine  
            },
....


大数据环境（未验证）

部署：

https://github.com/FederatedAI/FATE/blob/master/cluster-deploy/doc/thirdparty_spark/Hadoop+Spark%E9%9B%86%E7%BE%A4%E9%83%A8%E7%BD%B2%E6%8C%87%E5%8D%97.md

案例：

https://github.com/FederatedAI/FATE/blob/master/examples/federatedml-1.x-examples/hetero_logistic_regression/test_spark_backend_job_conf.json

