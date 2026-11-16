# 🍎 Guide Complet : Publication de l'Application Fès Country Club sur l'App Store Apple (Depuis Windows)

Ce guide détaille pas à pas la procédure pour envoyer et publier l'application **FCC Member** sur l'**Apple App Store**, sans avoir besoin d'un ordinateur Mac physique, grâce au pipeline automatisé de compilation dans le cloud.

---

## 📁 1. Architecture du projet iOS créé

Le projet iOS natif complet se trouve dans :
`C:\xampp\htdocs\royal-tennis-club\ios-member\`

- **`FCCMember.xcodeproj`** : Projet Xcode natif iOS (SwiftUI).
- **`FCCMember/Sources/`** :
  - **`FCCMemberApp.swift`** : Point d'entrée de l'application avec gestion du cycle de vie et auth.
  - **`Views/Login/LoginView.swift`** : Écran de connexion (Téléphone 10 chiffres + Code PIN + mode Famille).
  - **`Views/Login/PhotoCaptureView.swift`** : Prise de selfie / photo d'adhérent obligatoire.
  - **`Views/Dashboard/DashboardView.swift`** : Écran principal d'accueil membre.
  - **`Views/Dashboard/NotificationsSheetView.swift`** : Volet des notifications du club.
  - **`Views/Wallet/WalletSectionView.swift`** : Gestion du portefeuille RTCF & solde.
  - **`Views/Wallet/KioskCodeDialogView.swift`** : Générateur de code temporaire 15 min pour borne kiosque.
  - **`Views/Legal/LegalComplianceView.swift`** : Mentions légales, CGU et conformité CNDP Loi 09-08 (obligatoire Apple).
  - **`Services/MemberAPIService.swift`** : Client réseau API direct vers `https://erp.fescountry.club/api/`.
  - **`Services/QRCodeHelper.swift`** : Générateur natif de QR Code dynamique haute résolution pour tourniquets.
  - **`Services/SessionManager.swift`** : Gestion de session sécurisée.
- **`FCCMember/Assets.xcassets`** : Icônes d'application 1024x1024 et logos FCC officiels.
- **`FCCMember/Info.plist`** : Autorisations caméra, textes explicatifs Apple et conformité d'exportation.
- **`fastlane/`** et **`.github/workflows/`** : Automatisation de la compilation et upload vers l'App Store Connect.

---

## 🛠️ 2. Étape 1 : Créer l'Identifiant d'Application (App ID) sur Apple Developer

1. Rendez-vous sur [developer.apple.com/account](https://developer.apple.com/account).
2. Connectez-vous avec votre compte Apple Developer activé.
3. Dans le menu de gauche, cliquez sur **Certificates, Identifiers & Profiles** puis sur **Identifiers**.
4. Cliquez sur le bouton bleu **`+`** :
   - Choisissez **App IDs** > **App** > **Continue**.
   - **Description** : `Fes Country Club Member`
   - **Bundle ID** : Choisissez **Explicit** et entrez :
     `com.fcc.member`
   - Dans **Capabilities**, cochez **Push Notifications** (si vous souhaitez les notifications push APNs).
   - Cliquez sur **Continue** puis sur **Register**.

---

## 🚀 3. Étape 2 : Créer la Fiche de l'App dans App Store Connect

1. Rendez-vous sur [appstoreconnect.apple.com](https://appstoreconnect.apple.com/).
2. Cliquez sur **Mes apps (Apps)** puis sur le bouton bleu **`+`** > **Nouvelle app**.
3. Remplissez les champs suivants :
   - **Plateformes** : `iOS`
   - **Nom** : `Fès Country Club` (ou `Fes Country Club`)
   - **Langue principale** : `Français`
   - **ID de bundle** : Sélectionnez `com.fcc.member` (celui créé à l'étape 1).
   - **SKU** : `FCC-MEMBER-01`
   - **Accès utilisateur** : `Accès complet`
4. Cliquez sur **Créer**.

---

## 🔑 4. Étape 3 : Générer la Clé API App Store Connect (pour l'upload automatique depuis Windows)

Cette clé permet aux serveurs de compiler et d'envoyer l'application directement sur votre compte sans mot de passe :

1. Dans App Store Connect, cliquez sur **Utilisateurs et accès** (en haut de page).
2. Cliquez sur l'onglet **Intégrations** (ou **Clés** / **App Store Connect API**).
3. Cliquez sur **Générer une clé API** (ou le bouton `+`) :
   - **Nom** : `FCC Fastlane Cloud`
   - **Accès** : `Gestionnaire d'apps (App Manager)` ou `Admin`
4. Une fois générée :
   - Notez l'**Issuer ID** (ex: `69a6de70-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).
   - Notez l'**ID de clé (Key ID)** (ex: `2X9949XXXX`).
   - Téléchargez le fichier de clé privée **`.p8`** (ex: `AuthKey_2X9949XXXX.p8`). *Attention : Apple ne permet de le télécharger qu'une seule fois !*

---

## ☁️ 5. Étape 4 : Lancer la Compilation & l'Upload automatique (GitHub Actions)

Puisque vous êtes sous Windows, vous pouvez mettre ce dossier `ios-member` dans un dépôt GitHub (privé) :

1. Dans votre dépôt GitHub, allez dans **Settings** > **Secrets and variables** > **Actions** > **New repository secret**.
2. Ajoutez les secrets suivants :
   - **`APP_STORE_CONNECT_KEY_ID`** : Votre Key ID (ex: `2X9949XXXX`).
   - **`APP_STORE_CONNECT_ISSUER_ID`** : Votre Issuer ID UUID.
   - **`APP_STORE_CONNECT_PRIVATE_KEY`** : Ouvrez le fichier `.p8` avec le Bloc-notes, copiez tout son contenu (de `-----BEGIN PRIVATE KEY-----` à `-----END PRIVATE KEY-----`) et collez-le dans le secret.
   - **`APPLE_DEVELOPER_TEAM_ID`** : Votre Team ID Apple (10 lettres/chiffres visible en haut à droite sur `developer.apple.com`).
3. Allez dans l'onglet **Actions** de GitHub :
   - Sélectionnez le workflow **Build & Upload iOS App to App Store Connect**.
   - Cliquez sur **Run workflow** > Destination : `testflight` (ou `app_store`).
4. Le serveur Mac virtuel d'Apple dans le cloud va :
   - Compiler le projet Swift.
   - Créer le binaire `.ipa`.
   - L'envoyer directement sur votre compte App Store Connect !

---

## 📱 6. Étape 5 : TestFlight & Soumission Apple

1. Une fois l'upload terminé (environ 5 à 10 minutes), l'app apparaît dans l'onglet **TestFlight** sur App Store Connect.
2. Vous pouvez installer l'application **TestFlight** sur votre iPhone et tester l'application directement en conditions réelles !
3. Pour la mise en ligne publique sur l'App Store :
   - Dans l'onglet **Distribution App Store** de votre app sur App Store Connect :
     - Sélectionnez la version TestFlight validée.
     - Ajoutez la description, les mots-clés (`tennis, club, fès, country club, sport, accès`).
     - **URL de politique de confidentialité** : `https://erp.fescountry.club/reception/privacy` (ou l'URL du club).
     - Renseignez un compte de test pour l'équipe de validation Apple (ex: téléphone `0661000000` + PIN de test).
   - Cliquez sur **Envoyer pour validation**.
   - Apple valide généralement l'application sous 24h à 48h !
