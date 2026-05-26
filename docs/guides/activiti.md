# 1. 过程说明
      <process id="myProcess" name="My process" isExecutable="true" entityName="com.xxxx.Class">
        <startEvent id="startevent1" name="Start"></startEvent>
        <userTask id="write_apply" name="填写申请单" activiti:async="true" activiti:assignee="111" activiti:candidateUsers="111" activiti:candidateGroups="1111" activiti:dueDate="1111" activiti:category="111" activiti:formKey="lavel" activiti:priority="11" activiti:skipExpression="11111">
          <documentation>asdfasdfasdf</documentation>
          <extensionElements>
            <activiti:formProperty id="表单元素ID" name="表单元素名称" type="元素类型" expression="表达式" variable="变量" default="默认值" datePattern="日期格式化方式" required="true"></activiti:formProperty>
            <activiti:taskListener event="create" class="com.qing.time.web.core.workflow.listeners.GlobalEventListener">
              <activiti:field name="name">
                <activiti:string><![CDATA[aaaaa]]></activiti:string>
              </activiti:field>
            </activiti:taskListener>
          </extensionElements>
        </userTask>
        <userTask id="usertask2" name="User Task"></userTask>
        <sequenceFlow id="flow1" sourceRef="startevent1" targetRef="write_apply"></sequenceFlow>
        <sequenceFlow id="flow2" name="消息流" sourceRef="write_apply" targetRef="usertask2">
          <documentation>这里是文档内容。</documentation>
          <extensionElements>
            <activiti:executionListener event="take" class="org.alfresco.repo.workflow.activiti.tasklistener.ScriptTaskListener"></activiti:executionListener>
          </extensionElements>
          <conditionExpression xsi:type="tFormalExpression"><![CDATA[${aaaa>100}]]></conditionExpression>
        </sequenceFlow>
        <endEvent id="endevent1" name="End"></endEvent>
        <sequenceFlow id="flow3" sourceRef="usertask2" targetRef="endevent1"></sequenceFlow>
      </process>

## 1.1 主要属性说明
- entityName: 实体名称
- id: 过程ID
- name: 过程名称

# 2. TASK说明
    <userTask id="write_apply" name="填写申请单" activiti:async="true" activiti:assignee="111" activiti:candidateUsers="111" activiti:candidateGroups="1111" activiti:dueDate="1111" activiti:category="111" activiti:formKey="lavel" activiti:priority="11" activiti:skipExpression="11111">
      <documentation>asdfasdfasdf</documentation>
      <extensionElements>
        <activiti:formProperty id="表单元素ID" name="表单元素名称" type="元素类型" expression="表达式" variable="变量" default="默认值" datePattern="日期格式化方式" required="true"></activiti:formProperty>
        <activiti:taskListener event="create" class="com.qing.time.web.core.workflow.listeners.GlobalEventListener">
          <activiti:field name="name">
            <activiti:string><![CDATA[aaaaa]]></activiti:string>
          </activiti:field>
        </activiti:taskListener>
      </extensionElements>
    </userTask>

## 2.1 主要属性说明
- activiti:async -> 是否异步 true/false
- isForCompensation -> 是否补偿 true/false
- activiti:assignee -> 指定用户
- activiti:candidateUsers -> 分配用户 
- activiti:candidateGroups -> 分配角色
- activiti:dueDate -> 到期时间
- activiti:formKey -> 表单编号
- activiti:priority -> 优先级
- activiti:category -> 分类
- completionQuantity  -> 完成条件
- entityName -> 实体类名（自定义扩展属性）
- configInfo - > 节点配置信息（自定义扩展属性）
## 2.2 扩展元素说明
```
<extensionElements>
    <activiti:formProperty id="表单元素ID" name="表单元素名称" type="元素类型" expression="表达式" variable="变量" default="默认值" datePattern="日期格式化方式" required="true"></activiti:formProperty>
    <activiti:taskListener event="create" class="com.qing.time.web.core.workflow.listeners.GlobalEventListener">
        <activiti:field name="name">
            <activiti:string><![CDATA[aaaaa]]></activiti:string>
        </activiti:field>
    </activiti:taskListener>
</extensionElements>
```
### 2.2.1 表单属性说明
详见<activiti:formProperty>元素属性说明

### 2.2.2 事件元素说明
- event: 事件类型(下拉选择，有create, complete, assignment, all).
- class: 事件实现类（类全名）

# 3. SequenceFlow(消息流)
    <sequenceFlow id="flow2" name="消息流" sourceRef="write_apply" targetRef="usertask2">
      <documentation>这里是文档内容。</documentation>
      <extensionElements>
        <activiti:executionListener event="take" class="org.alfresco.repo.workflow.activiti.tasklistener.ScriptTaskListener"></activiti:executionListener>
      </extensionElements>
      <conditionExpression xsi:type="tFormalExpression"><![CDATA[${aaaa>100}]]></conditionExpression>
    </sequenceFlow>
## 2.1 事件说明
- event: 消息事件。下拉选择，只有一个值take.
- class: 消息事件实现类。
- conditionExpression: 条件表达式
