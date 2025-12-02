# 👋 Hi, I'm KAFKA

日常の行動・会話・お金・VR の活動を  
「記録して、整理して、また使えるようにするツール」としてコードにしています。

- VR のセッションを録音して自動で日記化する仕組み
- 動画・サムネ・台本の自動生成パイプライン
- 家計・投資・経済指標を扱うデータ分析ツール
- VRChat / 3D アバターまわりの補助ツール
- Windows × WSL × PowerShell まわりの自動起動・環境構築スクリプト

を、自分で本当に使いながら育てています。

<img width="1024" height="1024" alt="image" src="https://github.com/user-attachments/assets/e3cf75d9-a049-416a-943c-5f81bfa60c8d" />

---

## 🌱 About

- 🎮 VR / VRChat 周辺のログ収集・可視化・ツール作りが好きです  
- 💰 個人の家計・投資・経済データを数字で整理する仕組みを作っています  
- 🎥 「秒算マネー」などの動画制作を、自動生成パイプラインで回しています  
- 🖥 Windows / WSL / PowerShell / タスクスケジューラなど、環境構築と自動起動をよくいじります  
- 📚 ブログ・記事も書きます  
  - はてなブログ: https://kafkafinancialgroup.hatenablog.com/  
  - Zenn: https://zenn.dev/kafka2306
  - Note: https://note.com/kafkavr

---

## 🔹 Logging / Recording（行動・イベントの記録）

ログや履歴データを集めて、「あとから読み返せる記録」に変えるプロジェクトです。

- **[vlog](https://github.com/KAFKA2306/vlog)**  
  VR のセッションを録音し、文字起こし → 要約 → データベース保存 → Web 表示までつなげた記録パイプライン。

- **[vrcplat](https://github.com/KAFKA2306/vrcplat)**  
  VR 活動のログやセッション情報を集約し、ダッシュボードとして可視化するビューア。

- **[vrcviewer](https://github.com/KAFKA2306/vrcviewer)**  
  セッションログやスクリーンショットをブラウザから一覧できるビューア。

- **[trahist](https://github.com/KAFKA2306/trahist)**  
  取引履歴（トレードログ）を読み込み、損益推移や統計を計算するツール。

- **[econalert](https://github.com/KAFKA2306/econalert)**  
  経済指標やイベントの予定・結果を記録し、検証に使える形で管理するツール。

---

## 🔹 Automation（繰り返し作業の自動化）

日常的に発生する「同じパターンの作業」を、ワンコマンドで終わるようにしたプロジェクトです。

- **[2511youtuber](https://github.com/KAFKA2306/2511youtuber)**  
  台本生成・動画生成・サムネイル生成・アップロードまで、動画制作の手順を自動化したパイプライン。

- **[ytmanager](https://github.com/KAFKA2306/ytmanager)**  
  動画のメタデータ管理・アップロード処理をまとめた運営ツール。

- **[auto-invest](https://github.com/KAFKA2306/auto-invest)**  
  投資のルールやロジックをコードとして定義し、再現できるようにしたリポジトリ。

- **[boothitemmanager](https://github.com/KAFKA2306/boothitemmanager)**  
  商品データやメタ情報の管理をスクリプト化したツール。

- **[PictureChangerTools](https://github.com/KAFKA2306/PictureChangerTools)**  
  画像のサイズ変更・リネーム・一括変換など、面倒な作業をまとめて実行するツール。

- **[daily-arXiv-ai-enhanced](https://github.com/KAFKA2306/daily-arXiv-ai-enhanced)**  
  論文の取得 → 要約 → 公開までを自動で行う情報収集フローのリポジトリ。

---

## 🔹 Data / Finance（データの整理・可視化・モデル化）

数値データを集めて、判断や検証に使える形に整えるプロジェクトです。

- **[kakeibo](https://github.com/KAFKA2306/kakeibo)**  
  家計データを集計し、支出・収入の傾向を可視化するためのツール。

- **[finBI](https://github.com/KAFKA2306/finBI)**  
  金融データを扱うダッシュボードと分析ロジックをまとめたリポジトリ。

- **[financeLLM](https://github.com/KAFKA2306/financeLLM)**  
  ニュースやテキスト情報と株価データを組み合わせて分析する実験用リポジトリ。

- **[etf](https://github.com/KAFKA2306/etf) / [m2](https://github.com/KAFKA2306/m2) / [oil](https://github.com/KAFKA2306/oil) / [fx](https://github.com/KAFKA2306/fx) / [irr](https://github.com/KAFKA2306/irr) / [skew](https://github.com/KAFKA2306/skew)**  
  ETF、マネーサプライ、商品、為替、投資案件評価、リスク指標などを扱う分析用リポジトリ群。


---

## 🔹 Cloud / Integration（外部サービスとの連携）

外部サービスやアプリケーションプログラミングインターフェースと自作ツールをつなぐリポジトリです。

- **[kling](https://github.com/KAFKA2306/kling)**  
  動画生成サービスのアプリケーションプログラミングインターフェース クライアント。

- **[ComfyUI-KLingAI-API](https://github.com/KAFKA2306/ComfyUI-KLingAI-API)**  
  ComfyUI から上記アプリケーションプログラミングインターフェースを呼び出すノード・ワークフロー。

- **[UnityMCPforUbuntu22.04](https://github.com/KAFKA2306/UnityMCPforUbuntu22.04)**  
  Ubuntu 環境で Unity と Model Context Protocol を連携させるための設定・スクリプト。

- **[tradermade_cfd](https://github.com/KAFKA2306/tradermade_cfd) / [jquants-api-quick-start](https://github.com/KAFKA2306/jquants-api-quick-start) / [rakuten_rss](https://github.com/KAFKA2306/rakuten_rss)**  
  金融データのアプリケーションプログラミングインターフェース 連携を行うリポジトリ群。


---

## 🔹 VR / 3D / Avatar

3D モデルやアバターの調整・可視化・モーションを扱うツールです。

- **[open-fitter](https://github.com/KAFKA2306/open-fitter)**  
  体型調整や変形処理などを扱うアバター向けツールチェーンのフォーク。

- **[blendshapedeformer](https://github.com/KAFKA2306/blendshapedeformer)**  
  BlendShape を使った変形やエクスポートのためのツール。

- **[bpyutils](https://github.com/KAFKA2306/bpyutils)**  
  Blender の Python API を扱うときのユーティリティスクリプト集。

- **[molecularshader](https://github.com/KAFKA2306/molecularshader)**  
  分子構造を表示するためのシェーダーや表示まわりのコード。

- **[dancer](https://github.com/KAFKA2306/dancer)**  
  モーションや譜面データを扱う実験的リポジトリ。

- **[vmatch2](https://github.com/KAFKA2306/vmatch2) / [vmatching](https://github.com/KAFKA2306/vmatching)**  
  イベントやプレイヤー情報を整理・マッチングするツール。

---

## 🔹 Android / Utilities

日常の操作や開発体験を少し楽にするためのツールです。

- **[launcher](https://github.com/KAFKA2306/launcher)**  
  Android 向けのホームアプリ。ショートカットやレコメンドなど、よく使うアクションにすぐアクセスできるランチャー。

- **[readable-github](https://github.com/KAFKA2306/readable-github)**  
  GitHub の画面を読みやすくするカスタマイズ・スクリプト。

---

## 🛠 Tech Stack

**Languages**  
Python / TypeScript / Kotlin / C# / C++ / Rust / Bash / PowerShell

**Focus Areas**  
Logging / Data Engineering / Automation / Web Frontend / Backend / VR / 3D

**Tools / Platforms**  
Supabase / GitHub Actions / Cloudflare Workers / MCP / Unity / Blender / WSL2 / Windows Task Scheduler

---

## ✍ Writing

自筆

- Note: https://note.com/kafkavr

LLM出力

- はてなブログ（お金・戦略・技術メモなど）  
  - https://kafkafinancialgroup.hatenablog.com/
- Zenn（環境構築や実践ガイド系）  
  - https://zenn.dev/kafka2306
