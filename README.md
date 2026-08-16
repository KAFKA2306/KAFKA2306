# KAFKA2306

実際に使うデータ、作業、記録、判断を、**後から根拠・状態・失敗まで追えて、もう一度使える形**へ変えるソフトウェアを作っています。

<!-- ユーザー指定のプロフィール画像。README更新時も削除しないこと。 -->
<img width="1024" height="1024" alt="KAFKA2306 profile image" src="https://github.com/user-attachments/assets/e3cf75d9-a049-416a-943c-5f81bfa60c8d" />

## Mission

**アクセス可能な情報と想像力を、信頼できる証拠として収集・構造化し、再利用可能なデータ・ビュー・サービスへ変換して、利用・判断・実行につながる成果を生み出しながら、次の成果に必要なコード・複雑さ・コストを継続的に減らす。**

## Vision

多数のRepositoryを作ること自体が目的ではありません。投資、個人財務、VRChat、旅行、3D制作、ゲーム、AIエージェント運用で生まれる情報を、**「なぜそう判断したか」「今どの状態か」「どこまで信じて使えるか」まで再確認できるプロダクト**へ変えることを目指しています。

## Design philosophy

- 技術の新しさより、利用者が何を判断しやすくなるかを優先する
- 「動いた」だけで終わらせず、出典・入力・処理・成果物・公開状態を追跡できるようにする
- 実績、予測、推定、AI生成、人間判断を同じ事実として混ぜない
- 不明、未検証、失敗を正常値で埋めない
- public / private、canonical / snapshot、current / legacy を分ける
- automationは確認可能性を減らすためではなく、手戻りを減らすために使う

## Why / 差別化

差別化をPython、TypeScript、Unity、AIエージェントなどの技術stackそのものには置いていません。

共通して重視しているのは、便利なoutputを作るだけでなく、**そのoutputがどこから来て、どの状態で、どこまで信じて使えるかをUXとして見せること**です。

## Start here

| やりたいこと | 入口 |
|---|---|
| 投資・企業研究 | [investor](https://github.com/KAFKA2306/investor) · [investor2](https://github.com/KAFKA2306/investor2) · [semiconductor-earnings-model](https://github.com/KAFKA2306/semiconductor-earnings-model) |
| 個人財務 | [WealthAudit](https://github.com/KAFKA2306/WealthAudit) |
| VRChat・3D | [vlog](https://github.com/KAFKA2306/vlog) · [vrc_cast_event_calender](https://github.com/KAFKA2306/vrc_cast_event_calender) · [image2outfit](https://github.com/KAFKA2306/image2outfit) |
| 旅行 | [travel](https://github.com/KAFKA2306/travel) |
| ゲーム・趣味 | [rule-scribe-games](https://github.com/KAFKA2306/rule-scribe-games) · [game-library-dashboard](https://github.com/KAFKA2306/game-library-dashboard) · [furuyoni](https://github.com/KAFKA2306/furuyoni) |
| コンテンツ・AI運用 | [articles](https://github.com/KAFKA2306/articles) · [prompt-vault](https://github.com/KAFKA2306/prompt-vault) · [agent-resources](https://github.com/KAFKA2306/agent-resources) |

> **運用方針:** READMEは人間向けの正準入口。重要な作業状態はIssue、PR、commit、CI、公開URL、一次情報へ接続します。

---

## 公開サイト・Pages一覧

2026年8月5日に、各RepositoryのREADMEと公開設定を横断確認した公開URL台帳です。

- **正準**: 現在の主要な公開入口
- **補助**: API、個別ビュー、ドキュメント、ミラー
- **旧版・Snapshot**: 過去の試作、固定時点の研究成果、後継がある公開物

公開URLが存在することと、データの鮮度・計算の正しさ・デプロイ内容が現在のmainと一致することは別です。各サイトの状態表示、取得時刻、出典、Repositoryを確認してください。

### 正準の公開プロダクト

| 分野 | Project | Repository | 公開入口 | 主な追加入口 |
|---|---|---|---|---|
| 投資・企業 | investor | [GitHub](https://github.com/KAFKA2306/investor) | [Investor](https://kafka2306.github.io/investor/) | — |
| 投資研究 | investor2 | [GitHub](https://github.com/KAFKA2306/investor2) | [Evidence Dashboard](https://kafka2306.github.io/investor2/) | — |
| 半導体 | semiconductor-earnings-model | [GitHub](https://github.com/KAFKA2306/semiconductor-earnings-model) | [Research Portal](https://kafka2306.github.io/semiconductor-earnings-model/) | [Resilience](https://kafka2306.github.io/semiconductor-earnings-model/resilience/) · [Earnings](https://kafka2306.github.io/semiconductor-earnings-model/earnings/) · [Model](https://kafka2306.github.io/semiconductor-earnings-model/model/) |
| 定量研究 | CrewTrade | [GitHub](https://github.com/KAFKA2306/CrewTrade) | [Dashboard](https://kafka2306.github.io/CrewTrade/) | [Data Status](https://kafka2306.github.io/CrewTrade/data-status/) |
| 賞与分析 | bonus | [GitHub](https://github.com/KAFKA2306/bonus) | [Bonus Dashboard](https://kafka2306.github.io/bonus/) | — |
| アニメ | anime | [GitHub](https://github.com/KAFKA2306/anime) | [Year Catalogue](https://kafka2306.github.io/anime/) | [Explorer](https://kafka2306.github.io/anime/explore/) |
| 旅行 | travel | [GitHub](https://github.com/KAFKA2306/travel) | [Wayweave](https://kafka2306.github.io/travel/) | [Planner](https://kafka2306.github.io/travel/planner/) · [Destinations](https://kafka2306.github.io/travel/destinations/) · [Guides](https://kafka2306.github.io/travel/guides/) |
| VRChatイベント | vrc_cast_event_calender | [GitHub](https://github.com/KAFKA2306/vrc_cast_event_calender) | [Cloudflare Pages](https://vrc-cast-event-calender.pages.dev/) | [Tonight](https://vrc-cast-event-calender.pages.dev/tonight/) · [GitHub Pages mirror](https://kafka2306.github.io/vrc_cast_event_calender/) |
| プロンプト・画像 | prompt-vault | [GitHub](https://github.com/KAFKA2306/prompt-vault) | [Cloudflare Pages](https://prompt-vault-cg3.pages.dev/) | [GitHub Pages mirror](https://kafka2306.github.io/prompt-vault/) |
| BOOTH検索 | boothitemmanager | [GitHub](https://github.com/KAFKA2306/boothitemmanager) | [Cloudflare Pages](https://boothitemmanager.pages.dev/) | [AI tools](https://boothitemmanager.pages.dev/ai-tools.html) · [GitHub Pages mirror](https://kafka2306.github.io/boothitemmanager/) |
| AIエージェント | agent-resources | [GitHub](https://github.com/KAFKA2306/agent-resources) | [Documentation](https://kafka2306.github.io/agent-resources/) | — |
| ゲームデータ | pal-atlas | [GitHub](https://github.com/KAFKA2306/pal-atlas) | [PAL ATLAS](https://kafka2306.github.io/pal-atlas/) | [API index](https://kafka2306.github.io/pal-atlas/api/index.json) |
| ボードゲーム補助 | bodogenomikata2 | [GitHub](https://github.com/KAFKA2306/bodogenomikata2) | [ボドゲのミカタ](https://bodogenomikata2.pages.dev/) | — |
| ボードゲーム資料 | boardgamelist | [GitHub](https://github.com/KAFKA2306/boardgamelist) | [Rules Guide](https://kafka2306.github.io/boardgamelist/) | — |
| ふるよに | furuyoni | [GitHub](https://github.com/KAFKA2306/furuyoni) | [ふるよに統合ガイド](https://kafka2306.github.io/furuyoni/) | — |
| ブラウザゲーム | vrmine | [GitHub](https://github.com/KAFKA2306/vrmine) | [VRMine Game Hub](https://kafka2306.github.io/vrmine/) | [Answer Impostor](https://kafka2306.github.io/vrmine/games/answer-impostor/) · [深淵侵蝕](https://kafka2306.github.io/vrmine/games/abyss-invasion/) · [Stich-Meister](https://kafka2306.github.io/vrmine/games/stich-meister/) |
| テクスチャ | magicaltexture | [GitHub](https://github.com/KAFKA2306/magicaltexture) | [Hugging Face Space](https://k4fka-magicaltexture.hf.space) | [Guide](https://kafka2306.github.io/magicaltexture/) |
| 論文要約 | daily-arXiv-ai-enhanced | [GitHub](https://github.com/KAFKA2306/daily-arXiv-ai-enhanced) | [Daily arXiv](https://kafka2306.github.io/daily-arXiv-ai-enhanced/) | — |
| ゲーム所蔵 | game-library-dashboard | [GitHub](https://github.com/KAFKA2306/game-library-dashboard) | [Game Library](https://kafka2306.github.io/game-library-dashboard/) | — |
| 環境データ | cedar-pollen-bi | [GitHub](https://github.com/KAFKA2306/cedar-pollen-bi) | [Cedar Pollen BI](https://kafka2306.github.io/cedar-pollen-bi/) | — |
| 市場季節性 | nk225seasonality | [GitHub](https://github.com/KAFKA2306/nk225seasonality) | [Nikkei 225 Dashboard](https://kafka2306.github.io/nk225seasonality/) | — |
| 暗号資産 | option | [GitHub](https://github.com/KAFKA2306/option) | [Futures Report](https://kafka2306.github.io/option/) | — |
| 税計算 | furutsatotax | [GitHub](https://github.com/KAFKA2306/furutsatotax) | [ふるさと納税計算](https://kafka2306.github.io/furutsatotax/) | — |

### 研究資料・配信・固定Snapshot

| 区分 | Project | Repository | 公開先 | 注意 |
|---|---|---|---|---|
| Podcast配信 | nlm | [GitHub](https://github.com/KAFKA2306/nlm) | [RSS feed](https://kafka2306.github.io/nlm/feed.xml) | CLI本体とは別にPodcast feedを公開 |
| 経済Dashboard | m2 | [GitHub](https://github.com/KAFKA2306/m2) | [M2 Dashboard](https://kafka2306.github.io/m2/) | README記載の対象期間は2020–2025 |
| 麻雀練習 | mj | [GitHub](https://github.com/KAFKA2306/mj) | [Solo Mahjong](https://kafka2306.github.io/mj/) | Browser training prototype |
| Kaggle研究 | mitsuikaggle | [GitHub](https://github.com/KAFKA2306/mitsuikaggle) | [MkDocs](https://kafka2306.github.io/mitsuikaggle/) | 固定時点の競技・実験資料 |
| Swing研究 | us-swing-strategy-bi-pages | [GitHub](https://github.com/KAFKA2306/us-swing-strategy-bi-pages) | [Static BI](https://kafka2306.github.io/us-swing-strategy-bi-pages/) | 2026年6月22日時点の再構成Snapshot |
| Dominion計算 | DominionDeckDrawSimlator | [GitHub](https://github.com/KAFKA2306/DominionDeckDrawSimlator) | [Probability Calculator](https://kafka2306.github.io/DominionDeckDrawSimlator/) | 旧小規模ツール |
| 衣装需要 | hitaiall | [GitHub](https://github.com/KAFKA2306/hitaiall) | [GitHub Pages](https://kafka2306.github.io/hitaiall/) · [Netlify](https://effulgent-pixie-ec7b1e.netlify.app/) · [Lovable preview](https://preview--hitaiallconnect.lovable.app/) | 複数の旧公開先が残る |
| ルール検索 | rule-scribe-games | [GitHub](https://github.com/KAFKA2306/rule-scribe-games) | [Vercel](https://rule-scribe-games.vercel.app) | bodogenomikata2とは別系統の旧実装 |
| Memory reader旧系統 | vlogrs | [GitHub](https://github.com/KAFKA2306/vlogrs) | [KafLog](https://kaflog.vercel.app) | 現行vlogの正準設計とは別系統 |

### 公開API・データ入口

- [Semiconductor Financial Database v3 JSON](https://kafka2306.github.io/semiconductor-earnings-model/api/v3/financial-database/index.json)
- [Semiconductor Financial Database v3 SQLite](https://kafka2306.github.io/semiconductor-earnings-model/api/v3/financial-database/financial.db)
- [Semiconductor Research API v2](https://kafka2306.github.io/semiconductor-earnings-model/api/v2/semiconductor-research/index.json)
- [PAL ATLAS Pal catalog](https://kafka2306.github.io/pal-atlas/api/pals.json)
- [PAL ATLAS breeding pairs](https://kafka2306.github.io/pal-atlas/api/breeding.json)
- [VRChat Event JSON](https://vrc-cast-event-calender.pages.dev/events.json)
- [VRChat Event calendar](https://vrc-cast-event-calender.pages.dev/calendar.ics)
- [VRChat Event health](https://vrc-cast-event-calender.pages.dev/health.json)

---

## 現在の中心テーマ

## 1. 投資・企業・市場データ

企業開示、財務数値、金利、為替、仮説、予測、バックテスト、公開ダッシュボードを、同じ値として混ぜずに管理します。

- **[investor](https://github.com/KAFKA2306/investor)**  
  投資研究、企業知識DB/API、金利・為替DB、証拠優先の公開画面を統合した研究基盤。

- **[investor2](https://github.com/KAFKA2306/investor2)**  
  企業業績予測と証拠ダッシュボードを扱う別系統の研究基盤。

- **[semiconductor-earnings-model](https://github.com/KAFKA2306/semiconductor-earnings-model)**  
  半導体企業の決算、業績モデル、比較、レジリエンス分析を扱うプロジェクト。

- **[CrewTrade](https://github.com/KAFKA2306/CrewTrade)**  
  定量研究を、目的、データ、評価、証拠、制約と一緒に公開する研究カタログ。

- **[bonus](https://github.com/KAFKA2306/bonus)**  
  日本企業の賞与、利益、従業員還元などを比較する公開分析。

## 2. 個人財務

- **[WealthAudit](https://github.com/KAFKA2306/WealthAudit)**  
  収入、支出、資産、市場データから、実績と予測を分離した財務監査ダッシュボードを作るローカルワークスペース。

実際の家計・資産データは公開リポジトリへ保存しません。コード、schema、テスト、サンプルと、個人データの保存先を分離します。

## 3. VRChatの記録・イベント・体験

- **[vlog](https://github.com/KAFKA2306/vlog)**  
  音声、写真、会話、出来事、記憶、日記、公開物を区別して扱うHuman Memory Repository。

- **[vrc_cast_event_calender](https://github.com/KAFKA2306/vrc_cast_event_calender)**  
  VRChatイベントを、日時、参加方法、公式リンク、カテゴリ、開催形式、分類根拠と一緒に案内する公開カレンダー。

- **[image2outfit](https://github.com/KAFKA2306/image2outfit)**  
  参考画像から衣装アセットを制作し、Blender、FBX、Unity、Prefab、レンダリング証拠へつなぐ制作ライフサイクル。

## 4. 旅行知識と行程設計

- **[travel](https://github.com/KAFKA2306/travel)**  
  行き先の発見、候補比較、保存済み旅程の編集、交通や入域条件の公式確認を分けた旅行知識プロダクト。

公開画面: https://kafka2306.github.io/travel/

## 5. プロンプト・画像・デザイン資産

- **[prompt-vault](https://github.com/KAFKA2306/prompt-vault)**  
  画像生成プロンプトを再利用可能なblockへ分解し、生成画像、来歴、用途、静的サイトと一緒に管理する保管庫。

- **[agent-resources](https://github.com/KAFKA2306/agent-resources)**  
  Claude Code、Codex、Cursorなどで使うエージェント用スキルと共通資源を配布・同期するCLI。

- **[boothitemmanager](https://github.com/KAFKA2306/boothitemmanager)**  
  BOOTH商品の情報、比較、来歴、公開カタログを管理するツール。

---

## リポジトリの読み方

リポジトリごとに、READMEを人間向けの正準入口として整備しています。

READMEでは、原則として次を説明します。

- 何を解決するリポジトリか
- 現在できること
- 公開URLまたは実行方法
- 正準データと生成物
- セットアップと主要コマンド
- テスト、CI、公開確認
- セキュリティと公開境界
- 既知の制約、未完了、停止中の機能

`AGENTS.md`がある場合、そこにはAIエージェントが変更時に守る操作順序、禁止事項、完了条件を記録します。人間が全体を理解するためにAGENTS.mdを先に読む必要はありません。

---

## 横断管理

- **[com](https://github.com/KAFKA2306/com)**  
  複数リポジトリにまたがる指示、方針、意思決定、定期サービス、障害、完了証拠を管理するcommand repository。

日常の入口はChatGPTです。重要な仕事は会話だけに残さず、GitHubのIssue、PR、commit、CI、公開URL、一次情報へ接続します。

```text
自然言語の指示
  → 対象と受入条件を明確化
  → Issue / branch / PR
  → test / CI / runtime / Pagesを検証
  → 証拠を記録
  → 条件を満たした場合のみ完了
```

PRが作られたこと、CIが通ったこと、公開URLが存在することは、それぞれ別の証拠です。一つだけを見て全体完了とは判断しません。

---

## 開発で重視していること

### 一次情報と来歴

数値、仕様、日付、公開状態は、可能な限り公式資料、API、raw response、取得時刻、hashへ接続します。

### 実績と予測の分離

観測値、派生値、モデル予測、LLMによる解釈、実行結果を同じ欄へ混ぜません。

### 人間が確認できる成果物

テスト結果だけでなく、必要に応じて次を残します。

- 公開URL
- data table
- screenshot
- render
- multi-view画像
- workflow run
- commit SHA
- source URL

### 失敗を消さない

壊れた公開物、古いデータ、誤った計算、環境不足は、成功したように書き換えずIncident、警告、制約として記録します。

### 自動化の境界

自動処理は、判断の根拠や利用者の目的を置き換えるものではありません。scheduler、GitHub Actions、ローカルruntime、AIエージェントは交換可能な実行手段として扱います。

---

## 技術領域

| 領域 | 主な技術 |
|---|---|
| Data / ML | Python, pandas, PyTorch, scikit-learn, Optuna, MLflow |
| Web | TypeScript, React, Vite, HTML, CSS, Cloudflare, GitHub Pages |
| Database | PostgreSQL, PostGIS, Supabase, SQLite |
| Agent / Automation | ChatGPT, Codex, Claude Code, GitHub Actions, Taskfile, PowerShell |
| VR / 3D | VRChat, Blender, Unity, Modular Avatar |
| Local AI | WSL2, CUDA, llama.cpp, GGUF |

この一覧は、すべてのリポジトリが同じstackを使うという意味ではありません。各READMEとlockfileを現在の依存関係の正準として確認してください。

---

## 公開物・文章

- GitHub: https://github.com/KAFKA2306
- はてなブログ: https://kafkafinancialgroup.hatenablog.com/
- Scrapbox: https://scrapbox.io/kafka2512
- Zenn: https://zenn.dev/kafka2306
- YouTube: https://www.youtube.com/@byosan-money
- BOOTH: https://studiokafka.booth.pm/
- note: https://note.com/kafkavr
- ボドゲのミカタ: https://bodoge-no-mikata.vercel.app/

文章や動画には、本人が直接書いたものと、LLMを使って生成・編集したものがあります。媒体ごとの説明と根拠を確認してください。

---

## 注意事項

- 投資関連リポジトリは、投資助言、売買推奨、運用実績、将来収益の保証ではありません。
- 旅行、イベント、価格、時刻、法令、API仕様などは変更されるため、利用直前に公式情報を再確認してください。
- 公開リポジトリへAPIキー、token、認証情報、個人の家計、非公開会話などを保存しません。
- forkやsource snapshotは、独自製品と区別し、上流、差分、利用目的、ライセンスを各READMEへ記載します。

---

**プロフィールREADME・公開URL台帳監査:** 2026年8月5日