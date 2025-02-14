# 小红书净化主题包制作指南

## 主题包结构
主题包是一个文件夹，包含以下文件：

### 必需文件
- preview.png: 主题预览图 (建议尺寸: 800x600)
- icon.png: 主题图标 (建议尺寸: 120x120)

### 分享相关图标
- XYPHShareAppIcon~iphone.png: 分享应用图标
- XYPHSharePlayButton~iphone.png: 分享播放按钮
- XYPHShareSaveLocally~iphone.png: 本地保存按钮
- XYPHShareScreenShotWaterMark~iphone.png: 截图水印
- XYPHShareTopic~iphone.png: 分享话题图标

### 基础界面图标
- aboutus_logo~iphone.png: 关于页面logo
- launch_bg~iphone.png: 启动背景图
- launch_logo~iphone.png: 启动页logo
- login_tyrz_logo~iphone.png: 登录认证logo
- img_navBar~iphone.png: 导航栏背景

### 导航和操作图标
- navi_back~iphone.png: 返回按钮
- navi_shadow~iphone.png: 导航阴影
- imageViewerClose~iphone.png: 图片查看器关闭按钮
- icon_arrow_left~iphone.png: 左箭头
- icon_arrow_right~iphone.png: 右箭头

### 底部标签栏图标
- home_tab_hey~iphone.png: 首页标签
- home_tab_hey_dark~iphone.png: 首页标签(深色)
- home_tab_red_packet~iphone.png: 红包标签

### 功能按钮图标
- like~iphone.png: 点赞按钮
- board_add_new_icon~iphone.png: 新建收藏夹
- board_check_icon~iphone.png: 收藏夹选中
- board_private~iphone.png: 私密收藏夹
- check_mark_selected~iphone.png: 选中状态
- check_mark_unselected~iphone.png: 未选中状态

### 社交关注图标
- follow_wechat~iphone.png: 微信关注
- follow_wechat_gray~iphone.png: 微信关注(灰色)
- follow_weibo~iphone.png: 微博关注
- follow_weibo_gray~iphone.png: 微博关注(灰色)
- followed_btn_border~iphone.png: 已关注按钮边框

### 消息和通知图标
- message_default_avatar~iphone.png: 默认头像
- message_you_header_collect~iphone.png: 消息头部收藏
- message_you_header_follow~iphone.png: 消息头部关注
- message_you_header_like~iphone.png: 消息头部点赞
- notification_close_btn~iphone.png: 通知关闭按钮
- notification_tutor~iphone.png: 新手引导通知

### 状态和提示图标
- components_status_cactus~iphone.png: 仙人掌状态
- finger_pointer~iphone.png: 手指指示
- guidepoint_border~iphone.png: 引导点边框
- guidepoint_center~iphone.png: 引导点中心
- note_illegal~iphone.png: 违规笔记标记
- note_tag_all~iphone.png: 全部标签
- note_tag_arrow_right~iphone.png: 标签右箭头

### 视频相关图标
- gridcell_video_holder~iphone.png: 视频占位图
- video_content_big_oval~iphone.png: 视频大椭圆
- video_content_small_oval~iphone.png: 视频小椭圆
- video_content_play~iphone.png: 视频播放按钮
- video_content_illegal_icon~iphone.png: 视频违规图标
- video_content_illegal_accessery_icon~iphone.png: 视频违规附件

### 相机功能图标
- xy_camera_bck_btn~iphone.png: 相机返回
- xy_camera_bck_middle~iphone.png: 相机中间返回
- xy_camera_btn_click~iphone.png: 相机按钮
- xy_camera_btn_click_hover~iphone.png: 相机按钮悬停
- xy_camera_btn_flashauto~iphone.png: 闪光灯自动
- xy_camera_btn_flashoff~iphone.png: 闪光灯关闭
- xy_camera_btn_flashon~iphone.png: 闪光灯开启
- xy_camera_btn_grids~iphone.png: 相机网格
- xy_camera_btn_invert~iphone.png: 相机翻转
- xy_camera_cancel~iphone.png: 相机取消
- xy_camera_target~iphone.png: 相机对焦框

### 其他功能图标
- icon_c2c_grey_20~iphone.png: C2C图标(灰色)
- icon_delete_grey_15~iphone.png: 删除图标
- icon_following_grey_20~iphone.png: 关注图标
- icon_forwardarrow_grey_15~iphone.png: 前进箭头
- icon_hambugercollect_grey_20~iphone.png: 汉堡菜单收藏
- icon_message_grey_20~iphone.png: 消息图标
- icon_profile_grey_20~iphone.png: 个人资料图标
- icon_shopping_cart_check_12~iphone.png: 购物车勾选
- icon_store_close~iphone.png: 商店关闭
- icon_video_4G_indicator~iphone.png: 4G视频指示
- icon_vip_card~iphone.png: VIP卡片

## 图片要求
1. 格式: PNG格式，必须包含透明通道
2. 分辨率: 必须使用@2x分辨率
3. 命名规范: 
   - 必须严格按照上述文件名命名
   - 区分大小写
   - 支持~iphone和~iphone@2x两种后缀
4. 尺寸要求:
   - 必须严格按照原始图标尺寸
   - 建议使用矢量图设计工具制作
   - 导出时保持清晰度

## 安装方法
1. 创建主题文件夹，文件夹名即为主题名称
2. 将所有主题资源放入文件夹中
3. 将主题文件夹复制到以下路径:
   ```
   /var/mobile/Documents/DicCoverPure/
   ```
4. 重启小红书app后即可在主题设置中看到新主题

## 使用说明
1. 在小红书app中双击任意文本区域打开设置面板
2. 点击"主题"按钮进入主题设置
3. 选择想要使用的主题
4. 点击确定后重启app生效

## 注意事项
1. 主题包中的图片资源可以按需添加，不必包含所有文件
2. 未提供的图片将使用默认图片
3. 图片尺寸必须严格按照原始尺寸，否则可能显示异常
4. 建议使用矢量图设计工具(如Sketch/Figma)制作图标
5. 导出时注意保留透明通道
6. 文件名区分大小写，必须完全匹配
7. 主题切换后需要重启app才能完全生效
8. 建议定期备份主题包

## 示例主题
可以下载示例主题包作为参考:
[默认主题包下载](https://example.com/default_theme.zip)

## 常见问题
Q: 为什么有些图标没有更换?
A: 检查图片是否符合命名规范和尺寸要求

Q: 主题安装后没有显示?
A: 确认主题包路径是否正确，重启app后再试

Q: 图标显示不清晰?
A: 建议使用矢量图设计工具，确保导出@2x分辨率

## 技术支持
如有问题请加入Telegram群组讨论:
https://t.me/HyanguChat 