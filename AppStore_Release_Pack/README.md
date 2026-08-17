# 📦 Pongie (乒球人) - App Store 上架核心材料全套打包

本文件夹包含 **Pongie (乒球人)** iOS 应用提交至 Apple App Store Connect 所需的所有核心材料。

---

## 📂 目录结构索引

```
AppStore_Release_Pack/
├── 📝 AppStore_Metadata/
│   └── app_store_metadata.md            # ASO 优化标题、副标题、关键字、描述与审核指南 (中文名：乒球人)
├── 🖼️ AppStore_Screenshots/
│   ├── Screenshot_1_PhysicsPool_1284x2778.jpg # 截图 1：物理情绪球池
│   ├── Screenshot_2_GearLog_1284x2778.jpg     # 截图 2：装备日志与磨损提醒
│   ├── Screenshot_3_Analytics_1284x2778.jpg   # 截图 3：胜率与打法分析
│   └── Screenshot_4_Widgets_1284x2778.jpg     # 截图 4：iOS 桌面小组件 (含选型界面)
├── 🎨 App_Visual_Assets/
│   ├── AppIcon_1024x1024.jpg                  # 1024x1024 高清 App 图标
│   └── LaunchScreen_9x16.jpg                  # 9:16 启动引导页 (Launch Screen) 底图
└── 🌐 Websites/
    ├── privacy.html                           # 隐私政策 HTML 网页 (符合 Apple 规范)
    └── support.html                           # 技术支持 HTML 网页
```

---

## 🚀 快速提交指南 (Quick Submission Guide)

1. **App 视觉与图标设置：**
   - 将 `AppIcon_1024x1024.jpg` 作为 1024x1024 App Store Icon 上传，或配置到 Xcode Assets.xcassets 的 AppIcon 中。
   - 将 `LaunchScreen_9x16.jpg` 用于 Xcode LaunchScreen 视图背景或 9:16 启动过渡页。
2. **App Store Connect 截图：**
   - 拖拽 `AppStore_Screenshots/` 目录下的所有 1284x2778 (6.5寸 iPhone) 图片至 App Store Connect 的“iPhone 6.5 英寸显示屏”截图栏。
3. **文案元数据填写：**
   - 打开 `AppStore_Metadata/app_store_metadata.md`，复制对应的 App 名称（`Pongie - 乒球人打卡与装备日志`）、副标题、搜索关键字 (ASO)、App 描述和版本说明。
4. **网页挂载：**
   - 将 `Websites/privacy.html` 和 `support.html` 上传至 GitHub Pages / Vercel / Cloudflare Pages 等免费静态平台，并在 Connect 中填入对应链接。
