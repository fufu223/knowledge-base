# fastsun-workflow

## 模块概述

fastsun-workflow 是 Fastsun 平台的工作流模块，基于 Activiti 7.x 实现完整的业务流程管理功能。

**路径**: `fastsun-workflow/`

**主要职责**：
- 流程设计和部署
- 流程实例管理
- 任务审批和处理
- 流程监控和统计
- 动态节点添加

**子模块**：
- `workflow-common` - 工作流公共模块
- `workflow-engine` - 工作流引擎
- `workflow-designer` - 流程设计器
- `workflow-sdk` - SDK 接口

---

## 主要类

### 服务层

- `IFlowEngineService` - 流程引擎服务接口
- `IProcessService` - 流程定义服务
- `IModelService` - 流程模型服务
- `IDraftBoxService` - 草稿箱服务

### 控制器

- `TaskManageController` - 任务管理控制器
- `ProcessManageController` - 流程管理控制器

### 实体类

- `Process` - 流程定义
- `ProcessTask` - 流程任务
- `DraftBox` - 草稿箱

### DTO

- `ProcessDTO` - 流程定义 DTO
- `TaskDTO` - 任务 DTO
- `StartProcessRequest` - 启动流程请求
- `AgreeRequest` - 同意请求
- `RejectRequest` - 拒绝请求
- `BackRequest` - 退回请求

---

## 核心功能

### 1. 流程定义和管理

#### 部署流程

```java
@Autowired
private IProcessService processService;

// 部署 BPMN 文件
ProcessDTO process = new ProcessDTO();
process.setName("请假流程");
process.setKey("leave_process");
process.setModel(bpmnXml);  // BPMN XML 内容
process.setType(ProcessType.NORMAL.getCode());

processService.save(process);
```

#### 查询流程列表

```java
QueryParameter query = new QueryParameter();
query.addCondition("name", QueryOperator.LIKE, "%请假%");

FastsunPage<ProcessDTO> page = processService.page(query);
```

### 2. 启动流程

```java
@Autowired
private IFlowEngineService flowEngineService;

// 启动流程
StartProcessRequest request = new StartProcessRequest();
request.setProcessKey("leave_process");      // 流程 Key
request.setBusinessKey("LEAVE_001");         // 业务主键
request.setUserId(currentUserId);            // 发起人

// 设置流程变量
Map<String, Object> variables = new HashMap<>();
variables.put("days", 3);                    // 请假天数
variables.put("reason", "事假");              // 请假原因
request.setVariables(variables);

// 启动并返回流程实例
ProcessFormInstance instance = flowEngineService.startProcess(request);

String processInstanceId = instance.getProcessInstanceId();
```

### 3. 任务审批

#### 同意任务

```java
@Autowired
private IFlowEngineService flowEngineService;

AgreeRequest request = new AgreeRequest();
request.setTaskId(taskId);                   // 任务 ID
request.setComment("同意");                   // 审批意见
request.setUserId(currentUserId);            // 审批人

// 可选：设置下一节点的变量
Map<String, Object> variables = new HashMap<>();
variables.put("approved", true);
request.setVariables(variables);

flowEngineService.agreeTask(request);
```

#### 拒绝任务

```java
RejectRequest request = new RejectRequest();
request.setTaskId(taskId);
request.setComment("不同意，原因：...");
request.setUserId(currentUserId);

flowEngineService.rejectTask(request);
```

#### 退回任务

```java
BackRequest request = new BackRequest();
request.setTaskId(taskId);
request.setTargetNodeId("userTask1");        // 退回到指定节点
request.setComment("请补充材料");
request.setUserId(currentUserId);

flowEngineService.backTask(request);
```

### 4. 任务查询

#### 查询待办任务

```java
QueryParameter query = new QueryParameter();
query.addCondition("assignee", QueryOperator.EQ, currentUserId);
query.addCondition("status", QueryOperator.EQ, "ACTIVE");

FastsunPage<TaskDTO> todoList = flowEngineService.findTodoTasks(query);
```

#### 查询已办任务

```java
QueryParameter query = new QueryParameter();
query.addCondition("assignee", QueryOperator.EQ, currentUserId);
query.addCondition("status", QueryOperator.EQ, "COMPLETED");

FastsunPage<TaskDTO> doneList = flowEngineService.findDoneTasks(query);
```

#### 查询我发起的流程

```java
QueryParameter query = new QueryParameter();
query.addCondition("startUserId", QueryOperator.EQ, currentUserId);

FastsunPage<ProcessInstanceDTO> myProcesses = 
    flowEngineService.findMyProcesses(query);
```

### 5. 动态节点添加

在流程运行时动态添加审批节点：

```java
@Autowired
private IAddNodeService addNodeService;

AddNodeDTO request = new AddNodeDTO();
request.setTaskId(currentTaskId);            // 当前任务 ID
request.setNodeName("加签审批");               // 节点名称
request.setAssignees(Arrays.asList(userId1, userId2));  // 审批人
request.setNodeType("parallel");             // parallel:并行, sequential:串行

addNodeService.addNode(request);
```

### 6. 草稿箱功能

#### 保存草稿

```java
@Autowired
private IDraftBoxService draftBoxService;

DraftBoxDTO draft = new DraftBoxDTO();
draft.setBusinessKey("LEAVE_001");
draft.setProcessKey("leave_process");
draft.setContent(formData);                  // 表单数据 JSON

draftBoxService.save(draft);
```

#### 查询草稿

```java
QueryParameter query = new QueryParameter();
query.addCondition("userId", QueryOperator.EQ, currentUserId);
query.addCondition("processKey", QueryOperator.EQ, "leave_process");

List<DraftBoxDTO> drafts = draftBoxService.list(query);
```

#### 从草稿启动流程

```java
DraftBoxDTO draft = draftBoxService.getById(draftId);

StartProcessRequest request = new StartProcessRequest();
request.setProcessKey(draft.getProcessKey());
request.setBusinessKey(draft.getBusinessKey());
request.setVariables(JSONUtil.toBean(draft.getContent(), Map.class));

flowEngineService.startProcess(request);

// 删除草稿
draftBoxService.delete(draftId);
```

### 7. 流程跟踪

#### 查看流程图

```java
@Autowired
private IFlowEngineService flowEngineService;

// 获取流程图 PNG
InputStream diagram = flowEngineService.getProcessDiagram(processInstanceId);
```

#### 查看流程历史

```java
// 获取流程实例的历史记录
List<HistoricActivityInstance> history = 
    flowEngineService.getProcessHistory(processInstanceId);

// 每个活动实例包含：
// - activityId: 活动 ID
// - activityName: 活动名称
// - startTime: 开始时间
// - endTime: 结束时间
// - assignee: 办理人
// - duration: 耗时
```

---

## API 接口

### TaskManageController

#### GET `/workflow/task/todo`
**描述**: 查询待办任务列表

**请求参数**:
```
pageNum=1&pageSize=10&assignee={userId}
```

**响应**:
```json
{
  "code": 200,
  "data": {
    "total": 10,
    "list": [
      {
        "id": "task_001",
        "name": "部门经理审批",
        "processName": "请假流程",
        "assignee": "张三",
        "createTime": "2026-05-09 10:00:00",
        "variables": {
          "days": 3,
          "reason": "事假"
        }
      }
    ]
  }
}
```

#### POST `/workflow/task/agree`
**描述**: 同意任务

**请求体**:
```json
{
  "taskId": "task_001",
  "comment": "同意",
  "variables": {
    "approved": true
  }
}
```

#### POST `/workflow/task/reject`
**描述**: 拒绝任务

**请求体**:
```json
{
  "taskId": "task_001",
  "comment": "不同意"
}
```

#### POST `/workflow/task/back`
**描述**: 退回任务

**请求体**:
```json
{
  "taskId": "task_001",
  "targetNodeId": "userTask1",
  "comment": "请补充材料"
}
```

### ProcessManageController

#### POST `/workflow/process/start`
**描述**: 启动流程

**请求体**:
```json
{
  "processKey": "leave_process",
  "businessKey": "LEAVE_001",
  "variables": {
    "days": 3,
    "reason": "事假"
  }
}
```

**响应**:
```json
{
  "code": 200,
  "data": {
    "processInstanceId": "proc_inst_001",
    "businessKey": "LEAVE_001"
  }
}
```

#### GET `/workflow/process/history/{processInstanceId}`
**描述**: 查询流程历史

**响应**:
```json
{
  "code": 200,
  "data": [
    {
      "activityId": "startEvent",
      "activityName": "开始",
      "startTime": "2026-05-09 10:00:00",
      "endTime": "2026-05-09 10:00:01",
      "assignee": null
    },
    {
      "activityId": "userTask1",
      "activityName": "部门经理审批",
      "startTime": "2026-05-09 10:00:01",
      "endTime": "2026-05-09 11:00:00",
      "assignee": "张三"
    }
  ]
}
```

---

## 配置项

### Activiti 配置

```yaml
spring:
  activiti:
    # 是否检查流程定义
    check-process-definitions: true
    
    # 数据库 schema 更新策略
    database-schema-update: true
    
    # 历史记录级别：none, activity, audit, full
    history-level: full
    
    # 异步执行器
    async-executor-activate: true
```

### 多租户工作流配置

```yaml
fastsun:
  platform:
    workflow:
      # 是否为每个租户创建独立的流程引擎
      multi-tenant: true
      
      # 流程缓存配置
      cache:
        enabled: true
        ttl: 3600  # 缓存过期时间（秒）
```

---

## 使用示例

### 示例 1：完整的请假流程

**1. 定义流程（BPMN XML）**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL">
  <process id="leave_process" name="请假流程">
    
    <!-- 开始事件 -->
    <startEvent id="start" name="开始"/>
    
    <!-- 部门经理审批 -->
    <userTask id="deptManager" name="部门经理审批">
      <extensionElements>
        <activiti:candidateGroups>dept_manager</activiti:candidateGroups>
      </extensionElements>
    </userTask>
    
    <!-- HR 审批 -->
    <userTask id="hrApproval" name="HR审批">
      <extensionElements>
        <activiti:candidateGroups>hr</activiti:candidateGroups>
      </extensionElements>
    </userTask>
    
    <!-- 结束事件 -->
    <endEvent id="end" name="结束"/>
    
    <!-- 连线 -->
    <sequenceFlow sourceRef="start" targetRef="deptManager"/>
    <sequenceFlow sourceRef="deptManager" targetRef="hrApproval">
      <conditionExpression>${approved}</conditionExpression>
    </sequenceFlow>
    <sequenceFlow sourceRef="hrApproval" targetRef="end"/>
    
  </process>
</definitions>
```

**2. 部署流程**

```java
@PostMapping("/deploy")
public Response deployProcess(@RequestBody ProcessDTO process) {
    processService.save(process);
    return Response.success();
}
```

**3. 启动流程**

```java
@PostMapping("/apply")
public Response applyLeave(@RequestBody LeaveApplyRequest request) {
    StartProcessRequest startRequest = new StartProcessRequest();
    startRequest.setProcessKey("leave_process");
    startRequest.setBusinessKey(request.getLeaveId());
    
    Map<String, Object> variables = new HashMap<>();
    variables.put("days", request.getDays());
    variables.put("reason", request.getReason());
    variables.put("applicant", request.getApplicantId());
    startRequest.setVariables(variables);
    
    ProcessFormInstance instance = flowEngineService.startProcess(startRequest);
    
    return Response.success(instance);
}
```

**4. 审批任务**

```java
@PostMapping("/approve")
public Response approveTask(@RequestBody ApproveRequest request) {
    if (request.isApproved()) {
        AgreeRequest agreeRequest = new AgreeRequest();
        agreeRequest.setTaskId(request.getTaskId());
        agreeRequest.setComment(request.getComment());
        
        Map<String, Object> variables = new HashMap<>();
        variables.put("approved", true);
        agreeRequest.setVariables(variables);
        
        flowEngineService.agreeTask(agreeRequest);
    } else {
        RejectRequest rejectRequest = new RejectRequest();
        rejectRequest.setTaskId(request.getTaskId());
        rejectRequest.setComment(request.getComment());
        
        flowEngineService.rejectTask(rejectRequest);
    }
    
    return Response.success();
}
```

### 示例 2：会签流程

```xml
<!-- 并行网关 - 会签 -->
<parallelGateway id="fork" name="并行开始"/>
<parallelGateway id="join" name="并行结束"/>

<userTask id="manager1" name="经理1审批"/>
<userTask id="manager2" name="经理2审批"/>
<userTask id="manager3" name="经理3审批"/>

<sequenceFlow sourceRef="fork" targetRef="manager1"/>
<sequenceFlow sourceRef="fork" targetRef="manager2"/>
<sequenceFlow sourceRef="fork" targetRef="manager3"/>

<sequenceFlow sourceRef="manager1" targetRef="join"/>
<sequenceFlow sourceRef="manager2" targetRef="join"/>
<sequenceFlow sourceRef="manager3" targetRef="join"/>
```

所有经理都审批通过后，流程才会继续。

### 示例 3：条件分支

```xml
<exclusiveGateway id="decision" name="判断"/>

<sequenceFlow sourceRef="decision" targetRef="hrApproval">
  <conditionExpression>${days > 3}</conditionExpression>
</sequenceFlow>

<sequenceFlow sourceRef="decision" targetRef="end">
  <conditionExpression>${days <= 3}</conditionExpression>
</sequenceFlow>
```

请假天数大于 3 天需要 HR 审批，否则直接结束。

---

## 常见问题

### Q1: 如何获取当前登录用户的待办任务？

A:
```java
UserDTO user = LocalUserContext.get();

QueryParameter query = new QueryParameter();
query.addCondition("assignee", QueryOperator.EQ, user.getId());

FastsunPage<TaskDTO> todoList = flowEngineService.findTodoTasks(query);
```

### Q2: 如何在流程中传递业务数据？

A: 使用流程变量：

```java
// 启动时设置
Map<String, Object> variables = new HashMap<>();
variables.put("orderId", orderId);
variables.put("amount", amount);
request.setVariables(variables);

// 审批时更新
Map<String, Object> variables = new HashMap<>();
variables.put("approved", true);
variables.put("approveTime", new Date());
request.setVariables(variables);

// 在流程中使用 ${orderId}、${amount} 等
```

### Q3: 如何实现撤回功能？

A:
```java
// 撤回刚提交的任务（还未被审批）
public void withdraw(String processInstanceId) {
    // 查找当前活动任务
    Task task = taskService.createTaskQuery()
        .processInstanceId(processInstanceId)
        .singleResult();
    
    if (task != null) {
        // 删除任务
        taskService.deleteTask(task.getId(), true);
        
        // 结束流程
        runtimeService.deleteProcessInstance(processInstanceId, "撤回");
    }
}
```

### Q4: 如何监听流程事件？

A: 实现 ExecutionListener 或 TaskListener：

```java
@Component
public class MyTaskListener implements TaskListener {
    
    @Override
    public void notify(DelegateTask delegateTask) {
        String eventName = delegateTask.getEventName();
        
        if ("create".equals(eventName)) {
            // 任务创建时
            System.out.println("任务创建: " + delegateTask.getName());
        } else if ("complete".equals(eventName)) {
            // 任务完成时
            System.out.println("任务完成: " + delegateTask.getName());
        }
    }
}
```

在 BPMN 中配置：
```xml
<userTask id="task1" name="审批">
  <extensionElements>
    <activiti:taskListener event="create" delegateExpression="${myTaskListener}"/>
  </extensionElements>
</userTask>
```

---

## 相关文档

- [架构概述](../architecture/overview.md)
- [快速开始](../development/getting-started.md)
- [配置指南](../configuration/properties.md)
