#Requires -RunAsAdministrator
# =================================================================================================
# PROJETO: WDCx64 (WinDebloatCleanX64) - Ultimate Optimizer
# DESENVOLVEDOR: EduTechSoftware
# REPOSITORIO OFICIAL: https://github.com/EduTechSoftware/WDCx64
# LICENCA: MIT License
# =================================================================================================

# Carrega bibliotecas graficas e de sistema
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Drawing, System.Windows.Forms

# Oculta console em segundo plano e prepara API de memoria
if (-not ([System.Management.Automation.PSTypeName]'Win32.Win32API').Type) {
    Add-Type -Name Win32API -Namespace Win32 -MemberDefinition @"
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
[DllImport("psapi.dll")] public static extern int EmptyWorkingSet(IntPtr hwProc);
"@
}

$consoleHandle = [Win32.Win32API]::GetConsoleWindow()
if ($consoleHandle -ne [IntPtr]::Zero) { [void][Win32.Win32API]::ShowWindow($consoleHandle, 0) }

# Auto-elevacao
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    if ($PSCommandPath) {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -STA -File `"$PSCommandPath`"" -Verb RunAs
    } else {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass" -Verb RunAs
    }
    Exit
}

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls13

# -----------------------------------------------------------------------------------------------------------------
# 1. LISTA DE BLOATWARES EMBUTIDA
# -----------------------------------------------------------------------------------------------------------------
$Script:DefaultBloatware = @(
    "Clipchamp.Clipchamp", "Microsoft.3DBuilder", "Microsoft.549981C3F5F10", "Microsoft.BingFinance",
    "Microsoft.BingFoodAndDrink", "Microsoft.BingHealthAndFitness", "Microsoft.BingNews", "Microsoft.BingSports",
    "Microsoft.BingTranslator", "Microsoft.BingTravel", "Microsoft.BingWeather", "Microsoft.Getstarted",
    "Microsoft.Messaging", "Microsoft.Microsoft3DViewer", "Microsoft.MicrosoftJournal", "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftPowerBIForWindows", "Microsoft.MicrosoftSolitaireCollection", "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MixedReality.Portal", "Microsoft.NetworkSpeedTest", "Microsoft.News", "Microsoft.Office.OneNote",
    "Microsoft.Office.Sway", "Microsoft.OneConnect", "Microsoft.Print3D", "Microsoft.SkypeApp", "Microsoft.Todos",
    "Microsoft.WindowsAlarms", "Microsoft.WindowsFeedbackHub", "Microsoft.WindowsMaps", "Microsoft.WindowsSoundRecorder",
    "Microsoft.XboxApp", "Microsoft.ZuneVideo", "MicrosoftCorporationII.MicrosoftFamily", "MicrosoftCorporationII.QuickAssist",
    "MicrosoftTeams", "MSTeams", "ACGMediaPlayer", "ActiproSoftwareLLC", "AdobeSystemsIncorporated.AdobePhotoshopExpress",
    "Amazon.com.Amazon", "AmazonVideo.PrimeVideo", "Asphalt8Airborne", "AutodeskSketchBook", "CaesarsSlotsFreeCasino",
    "COOKINGFEVER", "CyberLinkMediaSuiteEssentials", "DisneyMagicKingdoms", "Disney", "DrawboardPDF",
    "Duolingo-LearnLanguagesforFree", "EclipseManager", "Facebook", "FarmVille2CountryEscape", "fitbit", "Flipboard",
    "HiddenCity", "HULULLC.HULUPLUS", "iHeartRadio", "Instagram", "king.com.BubbleWitch3Saga", "king.com.CandyCrushSaga",
    "king.com.CandyCrushSodaSaga", "LinkedInforWindows", "MarchofEmpires", "Netflix", "NYTCrossword", "OneCalendar",
    "PandoraMediaInc", "PhototasticCollage", "PicsArt-PhotoStudio", "Plex", "PolarrPhotoEditorAcademicEdition",
    "Royal Revolt", "Shazam", "Sidia.LiveWallpaper", "SlingTV", "Spotify", "TikTok", "TuneInRadio", "Twitter",
    "Viber", "WinZipUniversal", "Wunderlist", "XING"
)

# -----------------------------------------------------------------------------------------------------------------
# 2. CATALOGO COMPLETO DO WINUTIL (100+ APPS)
# -----------------------------------------------------------------------------------------------------------------
$Script:WinUtilCatalog = @(
    # Navegadores
    [PSCustomObject]@{ Name = "Google Chrome"; Id = "Google.Chrome"; Category = "Navegadores" },
    [PSCustomObject]@{ Name = "Brave Browser"; Id = "Brave.Brave"; Category = "Navegadores" },
    [PSCustomObject]@{ Name = "Mozilla Firefox"; Id = "Mozilla.Firefox"; Category = "Navegadores" },
    [PSCustomObject]@{ Name = "Firefox ESR"; Id = "Mozilla.Firefox.ESR"; Category = "Navegadores" },
    [PSCustomObject]@{ Name = "Microsoft Edge"; Id = "Microsoft.Edge"; Category = "Navegadores" },
    [PSCustomObject]@{ Name = "Vivaldi"; Id = "Vivaldi.Vivaldi"; Category = "Navegadores" },
    [PSCustomObject]@{ Name = "Tor Browser"; Id = "TorProject.TorBrowser"; Category = "Navegadores" },
    [PSCustomObject]@{ Name = "LibreWolf"; Id = "LibreWolf.LibreWolf"; Category = "Navegadores" },
    [PSCustomObject]@{ Name = "Waterfox"; Id = "Waterfox.Waterfox"; Category = "Navegadores" },
    [PSCustomObject]@{ Name = "Zen Browser"; Id = "Zen-Team.Zen-Browser"; Category = "Navegadores" },
    [PSCustomObject]@{ Name = "Ungoogled Chromium"; Id = "eloston.ungoogled-chromium"; Category = "Navegadores" },

    # Comunicacao
    [PSCustomObject]@{ Name = "WhatsApp Desktop"; Id = "msstore:9NKSQGP7F2NH"; Category = "Comunicacao" },
    [PSCustomObject]@{ Name = "Discord"; Id = "Discord.Discord"; Category = "Comunicacao" },
    [PSCustomObject]@{ Name = "Vesktop (Discord Leve)"; Id = "Vencord.Vesktop"; Category = "Comunicacao" },
    [PSCustomObject]@{ Name = "Telegram Desktop"; Id = "Telegram.TelegramDesktop"; Category = "Comunicacao" },
    [PSCustomObject]@{ Name = "Signal"; Id = "OpenWhisperSystems.Signal"; Category = "Comunicacao" },
    [PSCustomObject]@{ Name = "Mozilla Thunderbird"; Id = "Mozilla.Thunderbird"; Category = "Comunicacao" },
    [PSCustomObject]@{ Name = "Slack"; Id = "SlackTechnologies.Slack"; Category = "Comunicacao" },
    [PSCustomObject]@{ Name = "Zoom"; Id = "Zoom.Zoom"; Category = "Comunicacao" },

    # Jogos & Launchers
    [PSCustomObject]@{ Name = "Steam"; Id = "Valve.Steam"; Category = "Jogos & Launchers" },
    [PSCustomObject]@{ Name = "Epic Games Launcher"; Id = "EpicGames.EpicGamesLauncher"; Category = "Jogos & Launchers" },
    [PSCustomObject]@{ Name = "Battle.net"; Id = "Blizzard.BattleNet"; Category = "Jogos & Launchers" },
    [PSCustomObject]@{ Name = "EA App"; Id = "ElectronicArts.EADesktop"; Category = "Jogos & Launchers" },
    [PSCustomObject]@{ Name = "GOG Galaxy"; Id = "GOG.Galaxy"; Category = "Jogos & Launchers" },
    [PSCustomObject]@{ Name = "Ubisoft Connect"; Id = "Ubisoft.Connect"; Category = "Jogos & Launchers" },
    [PSCustomObject]@{ Name = "Heroic Games Launcher"; Id = "HeroicGamesLauncher.HeroicGamesLauncher"; Category = "Jogos & Launchers" },
    [PSCustomObject]@{ Name = "Playnite (Biblioteca)"; Id = "Playnite.Playnite"; Category = "Jogos & Launchers" },
    [PSCustomObject]@{ Name = "Prism Launcher (Minecraft)"; Id = "PrismLauncher.PrismLauncher"; Category = "Jogos & Launchers" },
    [PSCustomObject]@{ Name = "GeForce NOW"; Id = "Nvidia.GeForceNow"; Category = "Jogos & Launchers" },

    # Multimidia & Players
    [PSCustomObject]@{ Name = "K-Lite Codec Full"; Id = "CodecGuide.K-LiteCodecPack.Full"; Category = "Multimidia & Players" },
    [PSCustomObject]@{ Name = "VLC Media Player"; Id = "VideoLAN.VLC"; Category = "Multimidia & Players" },
    [PSCustomObject]@{ Name = "MPC-HC"; Id = "clsid2.mpc-hc"; Category = "Multimidia & Players" },
    [PSCustomObject]@{ Name = "mpv Player"; Id = "shinchiro.mpv"; Category = "Multimidia & Players" },
    [PSCustomObject]@{ Name = "OBS Studio"; Id = "OBSProject.OBSStudio"; Category = "Multimidia & Players" },
    [PSCustomObject]@{ Name = "Audacity"; Id = "Audacity.Audacity"; Category = "Multimidia & Players" },
    [PSCustomObject]@{ Name = "HandBrake"; Id = "HandBrake.HandBrake"; Category = "Multimidia & Players" },
    [PSCustomObject]@{ Name = "GIMP 3"; Id = "GIMP.GIMP.3"; Category = "Multimidia & Players" },
    [PSCustomObject]@{ Name = "Paint.NET"; Id = "dotPDN.PaintDotNet"; Category = "Multimidia & Players" },
    [PSCustomObject]@{ Name = "Blender"; Id = "BlenderFoundation.Blender"; Category = "Multimidia & Players" },
    [PSCustomObject]@{ Name = "ShareX (Print)"; Id = "ShareX.ShareX"; Category = "Multimidia & Players" },
    [PSCustomObject]@{ Name = "AIMP"; Id = "AIMP.AIMP"; Category = "Multimidia & Players" },
    [PSCustomObject]@{ Name = "foobar2000"; Id = "PeterPawlowski.foobar2000"; Category = "Multimidia & Players" },
    [PSCustomObject]@{ Name = "Notepad++"; Id = "Notepad++.Notepad++"; Category = "Multimidia & Players" },

    # Utilitarios & Sistema
    [PSCustomObject]@{ Name = "Snipping Tool (Captura)"; Id = "msstore:9MZ95Z3IZ001"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "Notepad Win11 (Bloco de Notas)"; Id = "msstore:9MSMLRH6LZF3"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "7-Zip"; Id = "7zip.7zip"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "NanaZip"; Id = "M2Team.NanaZip"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "WinRAR"; Id = "RARLab.WinRAR"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "PeaZip"; Id = "Giorgiotani.Peazip"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "PowerToys"; Id = "Microsoft.PowerToys"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "Everything (Busca Rapida)"; Id = "voidtools.Everything"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "Rufus (Boot USB)"; Id = "Rufus.Rufus"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "Bitwarden"; Id = "Bitwarden.Bitwarden"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "1Password"; Id = "AgileBits.1Password"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "KeePassXC"; Id = "KeePassXCTeam.KeePassXC"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "AnyDesk"; Id = "AnyDesk.AnyDesk"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "TeamViewer"; Id = "TeamViewer.TeamViewer"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "qBittorrent"; Id = "qBittorrent.qBittorrent"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "Revo Uninstaller"; Id = "RevoUninstaller.RevoUninstaller"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "Bulk Crap Uninstaller"; Id = "Klocman.BulkCrapUninstaller"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "Process Lasso"; Id = "BitSum.ProcessLasso"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "MSI Afterburner"; Id = "Guru3D.Afterburner"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "CrystalDiskInfo"; Id = "CrystalDewWorld.CrystalDiskInfo"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "CrystalDiskMark"; Id = "CrystalDewWorld.CrystalDiskMark"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "WizTree"; Id = "AntibodySoftware.WizTree"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "TreeSize Free"; Id = "JAMSoftware.TreeSize.Free"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "AutoHotkey"; Id = "AutoHotkey.AutoHotkey"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "Tailscale"; Id = "Tailscale.Tailscale"; Category = "Utilitarios & Sistema" },
    [PSCustomObject]@{ Name = "Cloudflare WARP"; Id = "Cloudflare.Warp"; Category = "Utilitarios & Sistema" },

    # Desenvolvimento & IA
    [PSCustomObject]@{ Name = "VS Code"; Id = "Microsoft.VisualStudioCode"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "VS Codium"; Id = "VSCodium.VSCodium"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "Cursor (AI Code)"; Id = "Anysphere.Cursor"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "Zed Editor"; Id = "ZedIndustries.Zed"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "Sublime Text 4"; Id = "SublimeHQ.SublimeText.4"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "Git"; Id = "Git.Git"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "GitHub Desktop"; Id = "GitHub.GitHubDesktop"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "GitHub CLI"; Id = "GitHub.cli"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "Docker Desktop"; Id = "Docker.DockerDesktop"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "Python 3.12"; Id = "Python.Python.3.12"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "NodeJS LTS"; Id = "OpenJS.NodeJS.LTS"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "Go (Golang)"; Id = "GoLang.Go"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "Rust"; Id = "Rustlang.Rust.MSVC"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "Neovim"; Id = "Neovim.Neovim"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "Postman"; Id = "Postman.Postman"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "ChatGPT Desktop"; Id = "msstore:9NT1R1C2HH7J"; Category = "Desenvolvimento & IA" },
    [PSCustomObject]@{ Name = "Claude Desktop"; Id = "Anthropic.Claude"; Category = "Desenvolvimento & IA" },

    # Documentos & Escritorio
    [PSCustomObject]@{ Name = "LibreOffice"; Id = "TheDocumentFoundation.LibreOffice"; Category = "Documentos & Escritorio" },
    [PSCustomObject]@{ Name = "ONLYOFFICE"; Id = "ONLYOFFICE.DesktopEditors"; Category = "Documentos & Escritorio" },
    [PSCustomObject]@{ Name = "Adobe Acrobat Reader"; Id = "Adobe.Acrobat.Reader.64-bit"; Category = "Documentos & Escritorio" },
    [PSCustomObject]@{ Name = "Foxit PDF Reader"; Id = "Foxit.FoxitReader"; Category = "Documentos & Escritorio" },
    [PSCustomObject]@{ Name = "PDF24 Creator"; Id = "geeksoftwareGmbH.PDF24Creator"; Category = "Documentos & Escritorio" },
    [PSCustomObject]@{ Name = "Sumatra PDF"; Id = "SumatraPDF.SumatraPDF"; Category = "Documentos & Escritorio" },
    [PSCustomObject]@{ Name = "Obsidian"; Id = "Obsidian.Obsidian"; Category = "Documentos & Escritorio" },
    [PSCustomObject]@{ Name = "Joplin"; Id = "Joplin.Joplin"; Category = "Documentos & Escritorio" },

    # Ferramentas Pro & Diagnostico
    [PSCustomObject]@{ Name = "CPU-Z"; Id = "CPUID.CPU-Z"; Category = "Ferramentas Pro" },
    [PSCustomObject]@{ Name = "GPU-Z"; Id = "TechPowerUp.GPU-Z"; Category = "Ferramentas Pro" },
    [PSCustomObject]@{ Name = "HWiNFO"; Id = "REALiX.HWiNFO"; Category = "Ferramentas Pro" },
    [PSCustomObject]@{ Name = "HWMonitor"; Id = "CPUID.HWMonitor"; Category = "Ferramentas Pro" },
    [PSCustomObject]@{ Name = "DDU Uninstaller"; Id = "Wagnardsoft.DisplayDriverUninstaller"; Category = "Ferramentas Pro" },
    [PSCustomObject]@{ Name = "Advanced IP Scanner"; Id = "Famatech.AdvancedIPScanner"; Category = "Ferramentas Pro" },
    [PSCustomObject]@{ Name = "Wireshark"; Id = "WiresharkFoundation.Wireshark"; Category = "Ferramentas Pro" },
    [PSCustomObject]@{ Name = "PuTTY"; Id = "PuTTY.PuTTY"; Category = "Ferramentas Pro" },
    [PSCustomObject]@{ Name = "WinSCP"; Id = "WinSCP.WinSCP"; Category = "Ferramentas Pro" },
    [PSCustomObject]@{ Name = "Ventoy"; Id = "Ventoy.Ventoy"; Category = "Ferramentas Pro" },
    [PSCustomObject]@{ Name = "Visual C++ 2015-2022 x64"; Id = "Microsoft.VCRedist.2015+.x64"; Category = "Ferramentas Pro" },
    [PSCustomObject]@{ Name = "Visual C++ 2015-2022 x86"; Id = "Microsoft.VCRedist.2015+.x86"; Category = "Ferramentas Pro" }
)

$Script:PulsingWindow = $null

# -----------------------------------------------------------------------------------------------------------------
# XAML - INTERFACE PROFISSIONAL COM SUA MARCA NO CABEÇALHO
# -----------------------------------------------------------------------------------------------------------------
$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinDebloatCleanX64 - Ultimate Optimizer"
        WindowStartupLocation="Manual"
        Background="#070C18" Foreground="#F8FAFC" FontFamily="Segoe UI"
        MinWidth="1050" MinHeight="720"
        ResizeMode="CanResizeWithGrip">
    
    <Window.Resources>
        <Style TargetType="ToolTip">
            <Setter Property="Background" Value="#061222"/>
            <Setter Property="Foreground" Value="#F1F5F9"/>
            <Setter Property="BorderBrush" Value="#00FF9D"/>
            <Setter Property="BorderThickness" Value="1.5"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="12,9"/>
            <Setter Property="MaxWidth" Value="460"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ToolTip">
                        <Border Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}" 
                                CornerRadius="6" 
                                Padding="{TemplateBinding Padding}"
                                MaxWidth="{TemplateBinding MaxWidth}">
                            <TextBlock Text="{TemplateBinding Content}" 
                                       TextWrapping="Wrap" 
                                       FontSize="{TemplateBinding FontSize}" 
                                       Foreground="{TemplateBinding Foreground}" 
                                       FontWeight="{TemplateBinding FontWeight}"
                                       LineStackingStrategy="BlockLineHeight"
                                       LineHeight="17"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="ModernButton" TargetType="Button">
            <Setter Property="Background" Value="#0284C7"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="11.5"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Padding" Value="10,4"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="btnBorder" Background="{TemplateBinding Background}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="btnBorder" Property="Opacity" Value="0.85"/></Trigger>
                            <Trigger Property="IsEnabled" Value="False"><Setter TargetName="btnBorder" Property="Opacity" Value="0.30"/></Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="PrimaryActionButton" TargetType="Button">
            <Setter Property="Background" Value="#00FF9D"/>
            <Setter Property="Foreground" Value="#000000"/>
            <Setter Property="FontWeight" Value="Black"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="BorderBrush" Value="#00FF9D"/>
            <Setter Property="BorderThickness" Value="1.5"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="pBorder" Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}" 
                                CornerRadius="6" Padding="12,6">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="pBorder" Property="Background" Value="#38BDF8"/>
                                <Setter TargetName="pBorder" Property="BorderBrush" Value="#38BDF8"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="pBorder" Property="Background" Value="#061811"/>
                                <Setter TargetName="pBorder" Property="BorderBrush" Value="#0D3826"/>
                                <Setter Property="Foreground" Value="#1E5C41"/>
                                <Setter Property="Cursor" Value="Arrow"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="BadgeCardButton" TargetType="Button">
            <Setter Property="Background" Value="#0A0604"/>
            <Setter Property="BorderBrush" Value="#FF7700"/>
            <Setter Property="BorderThickness" Value="1.2"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="cardBorder" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6" Padding="8,4">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="cardBorder" Property="Background" Value="#1A0D04"/>
                                <Setter TargetName="cardBorder" Property="BorderBrush" Value="#FFAA00"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="cardBorder" Property="Opacity" Value="0.95"/>
                                <Setter TargetName="cardBorder" Property="Background" Value="#080C14"/>
                                <Setter TargetName="cardBorder" Property="BorderBrush" Value="#00FF9D"/>
                                <Setter Property="Cursor" Value="Arrow"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="GamerButton" TargetType="Button">
            <Setter Property="Background" Value="#0E3327"/>
            <Setter Property="BorderBrush" Value="#00FF9D"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Foreground" Value="#00FF9D"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="FontSize" Value="10"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="gBorder" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="4">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="{TemplateBinding Padding}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="gBorder" Property="Background" Value="#154D3B"/></Trigger>
                            <Trigger Property="IsEnabled" Value="False"><Setter TargetName="gBorder" Property="Opacity" Value="0.30"/></Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="ToggleSwitch" TargetType="CheckBox">
            <Setter Property="Foreground" Value="#E2E8F0"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="Medium"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Margin" Value="0,1.5,0,1.5"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="CheckBox">
                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                            <Border x:Name="SwitchTrack" Width="30" Height="16" CornerRadius="8" Background="#1E293B" BorderBrush="#334155" BorderThickness="1" Margin="0,0,7,0">
                                <Border x:Name="SwitchThumb" Width="10" Height="10" CornerRadius="5" Background="#94A3B8" HorizontalAlignment="Left" Margin="2,0,0,0"/>
                            </Border>
                            <ContentPresenter VerticalAlignment="Center"/>
                        </StackPanel>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="SwitchTrack" Property="Background" Value="#0284C7"/>
                                <Setter TargetName="SwitchTrack" Property="BorderBrush" Value="#00FF9D"/>
                                <Setter TargetName="SwitchThumb" Property="Background" Value="#00FF9D"/>
                                <Setter TargetName="SwitchThumb" Property="HorizontalAlignment" Value="Right"/>
                                <Setter TargetName="SwitchThumb" Property="Margin" Value="0,0,2,0"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Opacity" Value="0.35"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Margin="10,8">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- 1. CABECALHO COM O LOGO E A SUA MARCA EDUTECHSOFTWARE -->
        <Border Grid.Row="0" Background="#0C1322" CornerRadius="8" BorderBrush="#1E2E4A" BorderThickness="1" Padding="10,7" Margin="0,0,0,6">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Grid Grid.Row="0" Margin="0,0,0,6">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                        <!-- LOGO COM ASSINATURA DA SUA MARCA -->
                        <Border Background="#060A14" CornerRadius="6" BorderBrush="#00A3FF" BorderThickness="1" Padding="8,4" Margin="0,0,8,0">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Grid Width="22" Height="22" Margin="0,0,10,0" VerticalAlignment="Center">
                                    <Grid.RowDefinitions><RowDefinition/><RowDefinition/></Grid.RowDefinitions>
                                    <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition/></Grid.ColumnDefinitions>
                                    <Border Grid.Row="0" Grid.Column="0" Background="#00A3FF" Margin="1" CornerRadius="1"/>
                                    <Border Grid.Row="0" Grid.Column="1" Background="#00A3FF" Margin="1" CornerRadius="1"/>
                                    <Border Grid.Row="1" Grid.Column="0" Background="#00A3FF" Margin="1" CornerRadius="1"/>
                                    <Border Grid.Row="1" Grid.Column="1" Background="#00FF9D" Margin="1" CornerRadius="1"/>
                                </Grid>

                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock FontSize="15.5" FontWeight="Black">
                                        <Run Text="WinDebloat" Foreground="#FFFFFF"/><Run Text="Clean" Foreground="#00A3FF"/><Run Text="X64" Foreground="#00FF9D"/>
                                    </TextBlock>
                                    <TextBlock Text="Windows mais leve e otimizado | by EduTechSoftware" FontSize="9.5" Foreground="#94A3B8" Margin="0,-1,0,0"/>
                                </StackPanel>
                            </StackPanel>
                        </Border>

                        <Button x:Name="btnCriarRestore" Style="{StaticResource BadgeCardButton}">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Grid Width="22" Height="22" Margin="0,0,9,0" VerticalAlignment="Center">
                                    <Path Data="M12,1 L3,5 L3,11 C3,16.55 6.84,21.74 12,23 C17.16,21.74 21,16.55 21,11 L21,5 Z" 
                                          Fill="#241002" Stroke="#FF7700" StrokeThickness="1.3" Stretch="Uniform"/>
                                    <Path Data="M9,12 L11.2,14.5 L15.5,9.5" 
                                          Stroke="#FFAA00" StrokeThickness="1.7" StrokeStartLineCap="Round" StrokeEndLineCap="Round" Stretch="Uniform" Margin="4.5"/>
                                </Grid>
                                
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock x:Name="lblRestoreTitle" Text="PONTO DE RESTAURACAO" FontSize="12.5" FontWeight="Black" Foreground="#FF7700"/>
                                    <TextBlock x:Name="lblRestoreStatus" Text="Obrigatorio - [ Clique para destravar o app ]" FontSize="9" FontWeight="Bold" Foreground="#FFAA00" Margin="0,-1,0,0"/>
                                </StackPanel>
                            </StackPanel>
                        </Button>
                    </StackPanel>

                    <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                        <TextBlock Text="Presets:" VerticalAlignment="Center" Foreground="#94A3B8" Margin="0,0,6,0" FontSize="11" FontWeight="SemiBold"/>
                        <Button x:Name="btnPresetPadrao" Content="Padrao" Background="#0284C7" Style="{StaticResource ModernButton}" Height="28" Margin="2,0" IsEnabled="False"/>
                        <Button x:Name="btnPresetRecomendado" Content="Recomendado" Background="#10B981" Style="{StaticResource ModernButton}" Height="28" Margin="2,0" IsEnabled="False"/>
                        <Button x:Name="btnPresetMaximo" Content="Ativar Modo Gamer" Background="#FF7700" Foreground="#000000" FontWeight="Bold" Height="28" Style="{StaticResource ModernButton}" Margin="2,0" IsEnabled="False"/>
                        <Button x:Name="btnDesmarcarTudo" Content="Desmarcar Tudo" Background="#334155" Style="{StaticResource ModernButton}" Height="28" Margin="2,0" IsEnabled="False"/>
                    </StackPanel>
                </Grid>

                <!-- TELEMETRIA DE HARDWARE -->
                <Border Grid.Row="1" Background="#060B17" CornerRadius="6" BorderBrush="#1E2E4A" BorderThickness="1" Padding="4,3">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="1.45*"/>
                            <ColumnDefinition Width="1.15*"/>
                            <ColumnDefinition Width="1.35*"/>
                            <ColumnDefinition Width="0.95*"/>
                            <ColumnDefinition Width="0.85*"/>
                            <ColumnDefinition Width="1.15*"/>
                        </Grid.ColumnDefinitions>

                        <Border Grid.Column="0" Background="#080E1E" CornerRadius="4" BorderBrush="#152238" BorderThickness="1" Padding="6,3" Margin="2,0">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Grid Width="16" Height="16" Margin="0,0,6,0" VerticalAlignment="Center">
                                    <Path Data="M4,4 H12 V12 H4 Z M6,6 H10 V10 H6 Z M2,6 H4 M2,10 H4 M12,6 H14 M12,10 H14 M6,2 V4 M10,2 V4 M6,12 V14 M10,12 V14" 
                                          Stroke="#38BDF8" StrokeThickness="1.2" Stretch="Uniform"/>
                                </Grid>
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="PROCESSADOR (CPU)" FontSize="8" FontWeight="Bold" Foreground="#38BDF8"/>
                                    <TextBlock x:Name="lblCPU" Text="Detectando..." FontSize="10.5" Foreground="#F8FAFC" TextTrimming="CharacterEllipsis"/>
                                </StackPanel>
                            </StackPanel>
                        </Border>

                        <Border Grid.Column="1" Background="#080E1E" CornerRadius="4" BorderBrush="#152238" BorderThickness="1" Padding="6,3" Margin="2,0">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Grid Width="16" Height="16" Margin="0,0,6,0" VerticalAlignment="Center">
                                    <Path Data="M2,2 H14 V14 H2 Z M4,4 H7 V7 H4 Z M10,4 H12 M10,6 H12 M4,10 H6 M9,10 H12 V12 H9 Z" 
                                          Stroke="#00A3FF" StrokeThickness="1.2" Stretch="Uniform"/>
                                </Grid>
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="PLACA-MAE" FontSize="8" FontWeight="Bold" Foreground="#38BDF8"/>
                                    <TextBlock x:Name="lblMotherboard" Text="Detectando..." FontSize="10.5" Foreground="#F8FAFC" TextTrimming="CharacterEllipsis"/>
                                </StackPanel>
                            </StackPanel>
                        </Border>

                        <Border Grid.Column="2" Background="#080E1E" CornerRadius="4" BorderBrush="#152238" BorderThickness="1" Padding="6,3" Margin="2,0">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Grid Width="16" Height="16" Margin="0,0,6,0" VerticalAlignment="Center">
                                    <Path Data="M2,4 H13 V11 H2 Z M4,11 V13 M7,11 V13 M13,2 V13 M5,6.5 A1.5,1.5 0 1 0 8,6.5 A1.5,1.5 0 1 0 5,6.5" 
                                          Stroke="#38BDF8" StrokeThickness="1.2" Stretch="Uniform"/>
                                </Grid>
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="PLACA DE VIDEO (GPU)" FontSize="8" FontWeight="Bold" Foreground="#38BDF8"/>
                                    <TextBlock x:Name="lblGPU" Text="Detectando..." FontSize="10.5" Foreground="#F8FAFC" TextTrimming="CharacterEllipsis"/>
                                </StackPanel>
                            </StackPanel>
                        </Border>

                        <Border Grid.Column="3" Background="#080E1E" CornerRadius="4" BorderBrush="#152238" BorderThickness="1" Padding="6,3" Margin="2,0">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Grid Width="16" Height="16" Margin="0,0,6,0" VerticalAlignment="Center">
                                    <Path Data="M2,5 H14 V11 H2 Z M4,11 V13 M6,11 V13 M10,11 V13 M12,11 V13 M4,7 H6 M8,7 H10 M12,7 H12.5" 
                                          Stroke="#00FF9D" StrokeThickness="1.2" Stretch="Uniform"/>
                                </Grid>
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="MEMORIA RAM" FontSize="8" FontWeight="Bold" Foreground="#38BDF8"/>
                                    <TextBlock x:Name="lblRAM" Text="Detectando..." FontSize="10.5" Foreground="#00FF9D" FontWeight="Bold"/>
                                </StackPanel>
                            </StackPanel>
                        </Border>

                        <Border Grid.Column="4" Background="#080E1E" CornerRadius="4" BorderBrush="#152238" BorderThickness="1" Padding="6,3" Margin="2,0">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Grid Width="16" Height="16" Margin="0,0,6,0" VerticalAlignment="Center">
                                    <Path Data="M2,4 H14 V12 H2 Z M4,9.5 H5 M11,9.5 H12 M2,8 H14" 
                                          Stroke="#38BDF8" StrokeThickness="1.2" Stretch="Uniform"/>
                                </Grid>
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="DISCOS (TOTAL)" FontSize="8" FontWeight="Bold" Foreground="#38BDF8"/>
                                    <TextBlock x:Name="lblDisk" Text="Detectando..." FontSize="10.5" Foreground="#F8FAFC"/>
                                </StackPanel>
                            </StackPanel>
                        </Border>

                        <Border Grid.Column="5" Background="#080E1E" CornerRadius="4" BorderBrush="#152238" BorderThickness="1" Padding="6,3" Margin="2,0">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Grid Width="16" Height="16" Margin="0,0,6,0" VerticalAlignment="Center">
                                    <Path Data="M2,3 H14 V10 H2 Z M5,13 H11 M8,10 V13 M4,6.5 L6,8.5 L9,5.5 L12,7" 
                                          Stroke="#F59E0B" StrokeThickness="1.2" StrokeLineJoin="Round" Stretch="Uniform"/>
                                </Grid>
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="PROCESSOS / TELA" FontSize="8" FontWeight="Bold" Foreground="#38BDF8"/>
                                    <TextBlock x:Name="lblProcRes" Text="Detectando..." FontSize="10.5" Foreground="#F59E0B" FontWeight="Bold"/>
                                </StackPanel>
                            </StackPanel>
                        </Border>
                    </Grid>
                </Border>
            </Grid>
        </Border>

        <!-- 2. ABAS NAVEGÁVEIS -->
        <StackPanel Grid.Row="1" Orientation="Horizontal" Margin="0,0,0,6">
            <Button x:Name="btnNavOtimizacao" Content="[ 1. Central de Otimizacao &amp; Gamer ]" Background="#0284C7" Foreground="#FFFFFF" FontWeight="Bold" FontSize="12" Padding="16,6" Margin="0,0,4,0" Style="{StaticResource ModernButton}"/>
            <Button x:Name="btnNavProgramas" Content="[ 2. Loja de Programas WinUtil (100+ Apps) ]" Background="#1E293B" Foreground="#94A3B8" FontWeight="Bold" FontSize="12" Padding="16,6" Style="{StaticResource ModernButton}" IsEnabled="False"/>
        </StackPanel>

        <!-- 3. CONTEÚDO DAS TELAS -->
        <Grid Grid.Row="2">
            
            <!-- TELA 1: CENTRAL DE OTIMIZAÇÃO -->
            <Grid x:Name="viewOtimizacao" Visibility="Visible" IsEnabled="False">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="1.05*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <!-- COLUNA 1 -->
                <Grid Grid.Column="0" Margin="0,0,4,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="1.25*"/>
                        <RowDefinition Height="1.25*"/>
                        <RowDefinition Height="0.8*"/>
                    </Grid.RowDefinitions>

                    <Border Grid.Row="0" Background="#0F172A" CornerRadius="6" BorderBrush="#1E293B" BorderThickness="1" Padding="8,5" Margin="0,0,0,5" VerticalAlignment="Stretch">
                        <StackPanel VerticalAlignment="Top">
                            <TextBlock Text="[ APLICATIVOS &amp; BLOATWARES ]" FontSize="11.5" FontWeight="Black" Foreground="#38BDF8" Margin="0,0,0,4"/>
                            <CheckBox x:Name="chkRemoveApps" Content="Remover Bloatwares Padrao de Fabrica" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Remove mais de 70 jogos e apps inuteis."/>
                            <CheckBox x:Name="chkRemoveGamingApps" Content="Remover Apps Xbox e Barra de Jogos" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Remove overlay de gravacao Xbox."/>
                            <CheckBox x:Name="chkRemoveCommApps" Content="Remover Email, Calendario e Pessoas" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Remove apps nativos de email/calendario."/>
                            <CheckBox x:Name="chkRemoveW11Outlook" Content="Remover Novo Outlook para Windows" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Desinstala o novo Outlook."/>
                            <CheckBox x:Name="chkRemoveDevApps" Content="Remover Apps Dev (DevHome, PowerAutomate)" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Remove DevHome e automacoes."/>
                            <CheckBox x:Name="chkForceRemoveEdge" Content="Forcar Desinstalacao do Microsoft Edge" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Remove o Microsoft Edge."/>
                            <CheckBox x:Name="chkUninstallOneDrive" Content="Desinstalar OneDrive e Bloquear Nuvem" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Desinstala o OneDrive."/>
                        </StackPanel>
                    </Border>

                    <Border Grid.Row="1" Background="#0F172A" CornerRadius="6" BorderBrush="#1E293B" BorderThickness="1" Padding="8,5" Margin="0,0,0,5" VerticalAlignment="Stretch">
                        <StackPanel VerticalAlignment="Top">
                            <TextBlock Text="[ PRIVACIDADE &amp; TELEMETRIA ]" FontSize="11.5" FontWeight="Black" Foreground="#38BDF8" Margin="0,0,0,4"/>
                            <CheckBox x:Name="chkDisableTelemetry" Content="Desativar Telemetria e Exterminar Google Updater" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Elimina envio de dados e bloqueia o Google Updater de forma 100% silenciosa."/>
                            <CheckBox x:Name="chkDisableBing" Content="Desativar Bing e WebView2 na Pesquisa (100% Local)" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Arranca o Edge WebView2 da pesquisa do Windows, liberando muita RAM."/>
                            <CheckBox x:Name="chkDisableSuggestions" Content="Desativar Dicas, Truques e Sugestoes" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Bloqueia anuncios e dicas."/>
                            <CheckBox x:Name="chkDisableLockscreenTips" Content="Desativar Dicas na Tela de Bloqueio" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Remove anuncios na tela de bloqueio."/>
                            <CheckBox x:Name="chkDisableCopilot" Content="Desativar e Remover Windows Copilot" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Desativa a IA Copilot."/>
                            <CheckBox x:Name="chkDisableRecall" Content="Desativar Capturas do Windows Recall" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Desativa o Recall."/>
                            <CheckBox x:Name="chkDisableDefenderFull" Content="Desativar Defender &amp; SmartScreen" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Desativa protecao em tempo real do Defender."/>
                        </StackPanel>
                    </Border>

                    <Border Grid.Row="2" Background="#0F172A" CornerRadius="6" BorderBrush="#1E293B" BorderThickness="1" Padding="8,5" VerticalAlignment="Stretch">
                        <StackPanel VerticalAlignment="Top">
                            <TextBlock Text="[ SERVICOS &amp; SISTEMA EM 2º PLANO ]" FontSize="11.5" FontWeight="Black" Foreground="#38BDF8" Margin="0,0,0,4"/>
                            <CheckBox x:Name="chkDisableWer" Content="Desativar Relatorios de Erro (WerSvc)" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Desativa relatorios de erro."/>
                            <CheckBox x:Name="chkDisableSensors" Content="Desativar Servicos de Mapas e Sensores" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Desativa geolocalizacao."/>
                            <CheckBox x:Name="chkDisableRetailDemo" Content="Desativar Servico Demo de Loja" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Desativa demonstracao de loja."/>
                            <CheckBox x:Name="chkDisableNearbyShare" Content="Desativar Compartilhamento Proximo" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Desativa compartilhamento Bluetooth."/>
                        </StackPanel>
                    </Border>
                </Grid>

                <!-- COLUNA 2 -->
                <Grid Grid.Column="1" Margin="3,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="1.55*"/>
                        <RowDefinition Height="1.25*"/>
                        <RowDefinition Height="0.7*"/>
                    </Grid.RowDefinitions>

                    <Border Grid.Row="0" Background="#0A1828" CornerRadius="6" BorderBrush="#00FF9D" BorderThickness="1.2" Padding="8,5" Margin="0,0,0,5" VerticalAlignment="Stretch">
                        <StackPanel VerticalAlignment="Top">
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,3">
                                <TextBlock Text="TURBO " FontSize="11" FontWeight="Black" Foreground="#38BDF8"/>
                                <TextBlock Text="GAMER FPS" FontSize="11" FontWeight="Black" Foreground="#00FF9D"/>
                                <TextBlock Text=" (Auto-Tuning Hardware)" FontSize="8.5" Foreground="#94A3B8" VerticalAlignment="Center" Margin="4,0,0,0"/>
                            </StackPanel>
                            
                            <Button x:Name="btnInstantGamerClean" Content="Limpar RAM &amp; Destravar GPU" Height="22" Margin="0,0,0,3" Style="{StaticResource GamerButton}" IsEnabled="False" ToolTip="Esvazia o Working Set e encerra processos fantasmas."/>

                            <CheckBox x:Name="chkGameHAGS" Content="HAGS - Agendamento GPU Hardware" Style="{StaticResource ToggleSwitch}" ToolTip="Reduz latencia de renderizacao."/>
                            <CheckBox x:Name="chkGameMMCSS" Content="MMCSS - Prioridade Maxima GPU (Nv 8)" Style="{StaticResource ToggleSwitch}" ToolTip="Prioridade maxima para jogos."/>
                            <CheckBox x:Name="chkGameCpuPriority" Content="CPU Foreground Quantum (0x26)" Style="{StaticResource ToggleSwitch}" ToolTip="Prioriza ciclos de CPU na tela ativa."/>
                            <CheckBox x:Name="chkGameNetworkLatency" Content="Ping Turbo - TCP NoDelay (Sem Nagle)" Style="{StaticResource ToggleSwitch}" ToolTip="Sem atraso em pacotes de rede."/>
                            <CheckBox x:Name="chkGameDvr" Content="Desativar GameDVR &amp; Input Lag" Style="{StaticResource ToggleSwitch}" ToolTip="Remove atraso no mouse/teclado."/>
                            <CheckBox x:Name="chkGameTimerRes" Content="Timer Resolution - Alta Precisao BCD" Style="{StaticResource ToggleSwitch}" ToolTip="Timer em 0.5ms sem stutterings."/>
                            <CheckBox x:Name="chkGameVisualFX" Content="Desativar Animacoes DWM (Mais VRAM)" Style="{StaticResource ToggleSwitch}" ToolTip="Libera memoria de video para os jogos."/>
                        </StackPanel>
                    </Border>

                    <Border Grid.Row="1" Background="#0F172A" CornerRadius="6" BorderBrush="#1E293B" BorderThickness="1" Padding="8,5" Margin="0,0,0,5" VerticalAlignment="Stretch">
                        <StackPanel VerticalAlignment="Top">
                            <TextBlock Text="[ BARRA DE TAREFAS &amp; MENU INICIAR ]" FontSize="11.5" FontWeight="Black" Foreground="#10B981" Margin="0,0,0,4"/>
                            <CheckBox x:Name="chkTaskbarAlignLeft" Content="Alinhar Icones da Barra a Esquerda" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Alinha como no Windows 10."/>
                            <CheckBox x:Name="chkHideSearchTb" Content="Ocultar Caixa de Pesquisa da Barra" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Oculta barra de busca."/>
                            <CheckBox x:Name="chkHideTaskview" Content="Ocultar Botao Visao de Tarefas (Task View)" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Remove atalho de multiplas areas."/>
                            <CheckBox x:Name="chkDisableWidgets" Content="Desativar Widgets (Noticias e Interesses)" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Desativa painel de noticias e clima."/>
                            <CheckBox x:Name="chkHideChat" Content="Ocultar Icone do Chat / Teams da Barra" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Remove atalho do Teams."/>
                            <CheckBox x:Name="chkClearStart" Content="Limpar Todos os Apps Fixados no Iniciar" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Limpa atalhos fixados no Iniciar."/>
                            <CheckBox x:Name="chkDisableDVR" Content="Desativar Gravacao Xbox DVR (Mais FPS)" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Desliga captura de clipes do Xbox."/>
                        </StackPanel>
                    </Border>

                    <Border Grid.Row="2" Background="#0F172A" CornerRadius="6" BorderBrush="#10B981" BorderThickness="1" Padding="8,5" VerticalAlignment="Stretch">
                        <StackPanel VerticalAlignment="Top">
                            <TextBlock Text="[ REDE &amp; CONEXOES RAPIDAS ]" FontSize="11.5" FontWeight="Black" Foreground="#10B981" Margin="0,0,0,4"/>
                            <CheckBox x:Name="chkNetThrottling" Content="Desativar Limitacao de Rede (100% Banda)" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Libera 100% da velocidade da internet."/>
                            <CheckBox x:Name="chkDisableTeredo" Content="Desativar Tunelamento Teredo (Menos Ping)" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Estabiliza conexoes multiplayer."/>
                            <CheckBox x:Name="chkPrioritizeNetwork" Content="Priorizar Pacotes de Jogos e Downloads" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Ajusta o SystemResponsiveness para 0."/>
                        </StackPanel>
                    </Border>
                </Grid>

                <!-- COLUNA 3 -->
                <Grid Grid.Column="2" Margin="4,0,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="1.5*"/>
                        <RowDefinition Height="0.45*"/>
                        <RowDefinition Height="1.25*"/>
                    </Grid.RowDefinitions>

                    <Border Grid.Row="0" Background="#0F172A" CornerRadius="6" BorderBrush="#1E293B" BorderThickness="1" Padding="8,5" Margin="0,0,0,5" VerticalAlignment="Stretch">
                        <StackPanel VerticalAlignment="Top">
                            <TextBlock Text="[ EXPLORADOR DE ARQUIVOS ]" FontSize="11.5" FontWeight="Black" Foreground="#F59E0B" Margin="0,0,0,4"/>
                            <CheckBox x:Name="chkShowKnownFileExt" Content="Exibir Extensoes (.exe, .txt)" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Exibe extensoes de arquivos."/>
                            <CheckBox x:Name="chkShowHiddenFolders" Content="Exibir Pastas Ocultas" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Torna pastas ocultas visiveis."/>
                            <CheckBox x:Name="chkHideDupliDrive" Content="Ocultar Unidades Duplicadas" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Remove icones duplicados no menu lateral."/>
                            <CheckBox x:Name="chkHideHome" Content="Ocultar Secao Inicio" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Abre direto em 'Este Computador'."/>
                            <CheckBox x:Name="chkHideGallery" Content="Ocultar Secao Galeria" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Oculta o botao Galeria do Windows 11."/>
                            <CheckBox x:Name="chkHide3dObjects" Content="Ocultar Pasta Objetos 3D" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Remove a pasta inutil Objetos 3D."/>
                            <CheckBox x:Name="chkHideIncludeInLibrary" Content="Ocultar 'Incluir na Biblioteca'" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Remove item do menu."/>
                            <CheckBox x:Name="chkHideGiveAccessTo" Content="Ocultar 'Conceder Acesso a'" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Remove item do menu."/>
                            <CheckBox x:Name="chkHideShare" Content="Ocultar 'Compartilhar'" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Remove item do menu."/>
                        </StackPanel>
                    </Border>

                    <Border Grid.Row="1" Background="#0F172A" CornerRadius="6" BorderBrush="#1E293B" BorderThickness="1" Padding="8,5" Margin="0,0,0,5" VerticalAlignment="Stretch">
                        <StackPanel VerticalAlignment="Top">
                            <TextBlock Text="[ MENU DE CONTEXTO (BOTAO DIREITO) ]" FontSize="11.5" FontWeight="Black" Foreground="#F59E0B" Margin="0,0,0,4"/>
                            <CheckBox x:Name="chkRevertContextMenu" Content="Restaurar Menu Classico (Windows 10)" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Volta ao menu classico do Win10."/>
                        </StackPanel>
                    </Border>

                    <Border Grid.Row="2" Background="#0F172A" CornerRadius="6" BorderBrush="#00FF9D" BorderThickness="1" Padding="8,5" VerticalAlignment="Stretch">
                        <StackPanel VerticalAlignment="Top">
                            <TextBlock Text="[ LIMPEZA PROFUNDA &amp; MANUTENCAO ]" FontSize="11.5" FontWeight="Black" Foreground="#00FF9D" Margin="0,0,0,4"/>
                            <CheckBox x:Name="chkCleanTemp" Content="Limpar Temporarios e Prefetch (%TEMP%)" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Apaga lixo digital das pastas TEMP."/>
                            <CheckBox x:Name="chkFlushDNS" Content="Limpar Cache de DNS e Icones" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Limpa registros de internet e icones."/>
                            <CheckBox x:Name="chkCleanWinUpdate" Content="Limpeza de Lixo do Windows Update" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Limpeza profunda DISM."/>
                            <CheckBox x:Name="chkDisableFastStartup" Content="Desativar Inicializacao Rapida (Evita Bugs)" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Evita acumulo de memoria corrompida."/>
                            <CheckBox x:Name="chkPowerUltimate" Content="Ativar Plano Desempenho Maximo" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Plano oculto de Desempenho Maximo."/>
                            <CheckBox x:Name="chkDisableUSBThrottling" Content="Desativar Economia em USB (Sem Lag)" IsChecked="True" Style="{StaticResource ToggleSwitch}" ToolTip="Impede corte de energia nas portas USB."/>
                            <CheckBox x:Name="chkRepairSFC" Content="Reparar Arquivos do Windows (SFC)" IsChecked="False" Style="{StaticResource ToggleSwitch}" ToolTip="Executa sfc /scannow."/>
                        </StackPanel>
                    </Border>
                </Grid>
            </Grid>

            <!-- TELA 2: LOJA DE PROGRAMAS WINUTIL -->
            <Grid x:Name="viewProgramas" Visibility="Collapsed" IsEnabled="False">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0" Background="#0C1322" CornerRadius="8" BorderBrush="#1E2E4A" BorderThickness="1" Padding="8,6" Margin="0,0,0,6">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>

                        <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                            <Button x:Name="btnSelectAllCatalog" Content="Marcar Todos" Background="#334155" Style="{StaticResource ModernButton}" Height="30" Padding="10,4" Margin="0,0,3,0"/>
                            <Button x:Name="btnClearCatalog" Content="Desmarcar" Background="#334155" Style="{StaticResource ModernButton}" Height="30" Padding="10,4" Margin="0,0,5,0"/>
                            <Button x:Name="btnInstallSelectedApps" Content="INSTALAR SELECIONADOS" Background="#00FF9D" Foreground="#000000" FontWeight="Bold" Height="30" Padding="14,4" Style="{StaticResource ModernButton}"/>
                        </StackPanel>

                        <StackPanel Grid.Column="1" HorizontalAlignment="Center" VerticalAlignment="Center">
                            <TextBlock Text="APLICATIVOS &amp; DOWNLOADS" FontSize="13.5" FontWeight="Black" Foreground="#00FF9D" HorizontalAlignment="Center"/>
                            <TextBlock Text="* Requer Microsoft Store" FontSize="9" Foreground="#94A3B8" HorizontalAlignment="Center" Margin="0,1,0,0"/>
                        </StackPanel>

                        <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center" HorizontalAlignment="Right">
                            <TextBlock Text="Buscar Programa:" FontSize="11.5" Foreground="#94A3B8" VerticalAlignment="Center" Margin="0,0,6,0"/>
                            <TextBox x:Name="txtSearchApp" Width="170" Height="28" FontSize="12" Background="#060B17" Foreground="#FFFFFF" BorderBrush="#334155" Padding="6,3" VerticalAlignment="Center"/>
                            <TextBlock x:Name="lblSelectedCount" Text=" (0 selecionados)" FontSize="11.5" Foreground="#00FF9D" VerticalAlignment="Center" Margin="6,0,0,0" FontWeight="Bold"/>
                        </StackPanel>
                    </Grid>
                </Border>

                <Border Grid.Row="1" Background="#070C18" CornerRadius="6" BorderBrush="#1E2E4A" BorderThickness="1" Padding="6,4">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel x:Name="spCategoryCards" Orientation="Vertical"/>
                    </ScrollViewer>
                </Border>
            </Grid>
        </Grid>

        <!-- 4. RODAPÉ DE EXECUÇÃO -->
        <Border Grid.Row="3" Background="#0C1322" CornerRadius="8" BorderBrush="#1E2E4A" BorderThickness="1" Padding="10,7" Margin="0,6,0,0">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="1.2*"/>
                    <ColumnDefinition Width="1.35*"/>
                    <ColumnDefinition Width="1.45*"/>
                </Grid.ColumnDefinitions>

                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,10,0">
                    <TextBlock x:Name="lblStatus" Text="SISTEMA BLOQUEADO: Clique no cartao 'PONTO DE RESTAURACAO' acima para destravar." 
                               FontSize="10.5" Foreground="#FF7700" FontWeight="Bold" Margin="0,0,0,4" TextTrimming="CharacterEllipsis"/>
                    <ProgressBar x:Name="pbProgress" Height="7" Value="0" Maximum="100" Background="#1E293B" Foreground="#00FF9D" BorderThickness="0">
                        <ProgressBar.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="3"/></Style></ProgressBar.Resources>
                    </ProgressBar>
                </StackPanel>

                <Button x:Name="btnRun" Grid.Column="1" Content="[ EXECUTAR OTIMIZACAO ]" 
                        Style="{StaticResource PrimaryActionButton}"
                        Height="38" Margin="6,0" IsEnabled="False"/>

                <!-- CARD REINICIAR WINDOWS -->
                <Border Grid.Column="2" Background="#080E1E" CornerRadius="6" BorderBrush="#1E2E4A" BorderThickness="1.2" Padding="10,5" HorizontalAlignment="Stretch" VerticalAlignment="Stretch">
                    <Grid VerticalAlignment="Center">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,10,0">
                            <TextBlock Text="REINICIAR WINDOWS?" FontSize="13" FontWeight="Black" Foreground="#FFFFFF"/>
                            <TextBlock Text="Regressiva 25s" FontSize="10" FontWeight="Bold" Foreground="#FF7700" Margin="0,1,0,0"/>
                        </StackPanel>

                        <Grid Grid.Column="1" VerticalAlignment="Center">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <Button x:Name="btnRestartSim" Grid.Column="0" Content="SIM" Background="#059669" Foreground="#FFFFFF" FontWeight="Black" Height="32" FontSize="12.5" Margin="0,0,3,0" Cursor="Hand" Style="{StaticResource ModernButton}" IsEnabled="False" HorizontalAlignment="Stretch"/>
                            <Button x:Name="btnRestartNao" Grid.Column="1" Content="NAO" Background="#1E293B" Foreground="#94A3B8" FontWeight="Black" Height="32" FontSize="12.5" Margin="3,0,0,0" Cursor="Hand" Style="{StaticResource ModernButton}" IsEnabled="False" HorizontalAlignment="Stretch"/>
                        </Grid>
                    </Grid>
                </Border>
            </Grid>
        </Border>
    </Grid>
</Window>
'@

# Carregamento do XAML
$xmlReader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($xmlReader)

# Centralizacao e Dimensoes Iniciais Otimizadas
$workArea = [System.Windows.SystemParameters]::WorkArea
$targetWidth = [math]::Min(1240, $workArea.Width * 0.94)
$targetHeight = [math]::Min(830, $workArea.Height * 0.92)

$window.Width = $targetWidth
$window.Height = $targetHeight
$window.Left = $workArea.Left + (($workArea.Width - $targetWidth) / 2)
$window.Top = $workArea.Top + (($workArea.Height - $targetHeight) / 2)

# Mapeia Controles
$btnNavOtimizacao = $window.FindName("btnNavOtimizacao")
$btnNavProgramas = $window.FindName("btnNavProgramas")
$viewOtimizacao = $window.FindName("viewOtimizacao")
$viewProgramas = $window.FindName("viewProgramas")

$btnCriarRestore = $window.FindName("btnCriarRestore")
$lblRestoreTitle = $window.FindName("lblRestoreTitle")
$lblRestoreStatus = $window.FindName("lblRestoreStatus")
$lblStatus = $window.FindName("lblStatus")
$pbProgress = $window.FindName("pbProgress")
$btnRun = $window.FindName("btnRun")
$btnInstantGamerClean = $window.FindName("btnInstantGamerClean")
$btnRestartSim = $window.FindName("btnRestartSim")
$btnRestartNao = $window.FindName("btnRestartNao")

$lblCPU = $window.FindName("lblCPU")
$lblMotherboard = $window.FindName("lblMotherboard")
$lblGPU = $window.FindName("lblGPU")
$lblRAM = $window.FindName("lblRAM")
$lblDisk = $window.FindName("lblDisk")
$lblProcRes = $window.FindName("lblProcRes")

$btnPresetPadrao = $window.FindName("btnPresetPadrao")
$btnPresetRecomendado = $window.FindName("btnPresetRecomendado")
$btnPresetMaximo = $window.FindName("btnPresetMaximo")
$btnDesmarcarTudo = $window.FindName("btnDesmarcarTudo")

$txtSearchApp = $window.FindName("txtSearchApp")
$lblSelectedCount = $window.FindName("lblSelectedCount")
$btnSelectAllCatalog = $window.FindName("btnSelectAllCatalog")
$btnClearCatalog = $window.FindName("btnClearCatalog")
$btnInstallSelectedApps = $window.FindName("btnInstallSelectedApps")
$spCategoryCards = $window.FindName("spCategoryCards")

$chkRemoveApps = $window.FindName("chkRemoveApps")
$chkRemoveGamingApps = $window.FindName("chkRemoveGamingApps")
$chkRemoveCommApps = $window.FindName("chkRemoveCommApps")
$chkRemoveW11Outlook = $window.FindName("chkRemoveW11Outlook")
$chkRemoveDevApps = $window.FindName("chkRemoveDevApps")
$chkForceRemoveEdge = $window.FindName("chkForceRemoveEdge")
$chkUninstallOneDrive = $window.FindName("chkUninstallOneDrive")

$chkDisableTelemetry = $window.FindName("chkDisableTelemetry")
$chkDisableBing = $window.FindName("chkDisableBing")
$chkDisableSuggestions = $window.FindName("chkDisableSuggestions")
$chkDisableLockscreenTips = $window.FindName("chkDisableLockscreenTips")
$chkDisableCopilot = $window.FindName("chkDisableCopilot")
$chkDisableRecall = $window.FindName("chkDisableRecall")
$chkDisableDefenderFull = $window.FindName("chkDisableDefenderFull")

$chkDisableWer = $window.FindName("chkDisableWer")
$chkDisableSensors = $window.FindName("chkDisableSensors")
$chkDisableRetailDemo = $window.FindName("chkDisableRetailDemo")
$chkDisableNearbyShare = $window.FindName("chkDisableNearbyShare")

$chkGameHAGS = $window.FindName("chkGameHAGS")
$chkGameMMCSS = $window.FindName("chkGameMMCSS")
$chkGameCpuPriority = $window.FindName("chkGameCpuPriority")
$chkGameNetworkLatency = $window.FindName("chkGameNetworkLatency")
$chkGameDvr = $window.FindName("chkGameDvr")
$chkGameTimerRes = $window.FindName("chkGameTimerRes")
$chkGameVisualFX = $window.FindName("chkGameVisualFX")

$chkTaskbarAlignLeft = $window.FindName("chkTaskbarAlignLeft")
$chkHideSearchTb = $window.FindName("chkHideSearchTb")
$chkHideTaskview = $window.FindName("chkHideTaskview")
$chkDisableWidgets = $window.FindName("chkDisableWidgets")
$chkHideChat = $window.FindName("chkHideChat")
$chkClearStart = $window.FindName("chkClearStart")
$chkDisableDVR = $window.FindName("chkDisableDVR")

$chkNetThrottling = $window.FindName("chkNetThrottling")
$chkDisableTeredo = $window.FindName("chkDisableTeredo")
$chkPrioritizeNetwork = $window.FindName("chkPrioritizeNetwork")

$chkShowKnownFileExt = $window.FindName("chkShowKnownFileExt")
$chkShowHiddenFolders = $window.FindName("chkShowHiddenFolders")
$chkHideHome = $window.FindName("chkHideHome")
$chkHideGallery = $window.FindName("chkHideGallery")
$chkHideDupliDrive = $window.FindName("chkHideDupliDrive")
$chkHide3dObjects = $window.FindName("chkHide3dObjects")
$chkHideIncludeInLibrary = $window.FindName("chkHideIncludeInLibrary")
$chkHideGiveAccessTo = $window.FindName("chkHideGiveAccessTo")
$chkHideShare = $window.FindName("chkHideShare")
$chkRevertContextMenu = $window.FindName("chkRevertContextMenu")

$chkCleanTemp = $window.FindName("chkCleanTemp")
$chkFlushDNS = $window.FindName("chkFlushDNS")
$chkCleanWinUpdate = $window.FindName("chkCleanWinUpdate")
$chkDisableFastStartup = $window.FindName("chkDisableFastStartup")
$chkPowerUltimate = $window.FindName("chkPowerUltimate")
$chkDisableUSBThrottling = $window.FindName("chkDisableUSBThrottling")
$chkRepairSFC = $window.FindName("chkRepairSFC")

function Update-UI {
    param([string]$Message, [int]$Percent)
    $lblStatus.Text = $Message
    $pbProgress.Value = $Percent
    [System.Windows.Forms.Application]::DoEvents()
}

# -----------------------------------------------------------------------------------------------------------------
# 3. CRONOMETRO E BALOES COM BORDAS LARANJA ACENTUADAS E PONTAS ARREDONDADAS
# -----------------------------------------------------------------------------------------------------------------

function Show-CountdownWindow {
    $cdXaml = @'
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            Title="Reinicializacao do Sistema" Width="440" Height="210"
            WindowStartupLocation="CenterScreen" Background="#080D1A"
            Foreground="#F8FAFC" FontFamily="Segoe UI" WindowStyle="None"
            Topmost="True" ResizeMode="NoResize" BorderBrush="#FF6600" BorderThickness="3">
        <Border CornerRadius="12" Background="#0C1322" Padding="20">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>
                <TextBlock Grid.Row="0" Text="REINICIALIZACAO AGENDADA" FontSize="15" FontWeight="Black" Foreground="#38BDF8" HorizontalAlignment="Center"/>
                <TextBlock x:Name="lblCD" Text="Reiniciando em 25 segundos..." Grid.Row="1" FontSize="13" FontWeight="Bold" Foreground="#FF6600" HorizontalAlignment="Center" Margin="0,10,0,10"/>
                <ProgressBar x:Name="pbCD" Grid.Row="2" Height="8" Maximum="25" Value="25" Background="#1E293B" Foreground="#FF6600" BorderThickness="0" Margin="0,0,0,14"/>
                <Button x:Name="btnCancelRestart" Grid.Row="3" Content="CANCELAR REINICIALIZACAO" Background="#DC2626" Foreground="#FFFFFF" FontSize="11" FontWeight="Bold" Height="34" Cursor="Hand" BorderThickness="0">
                    <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
                </Button>
            </Grid>
        </Border>
    </Window>
'@
    $cdReader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($cdXaml))
    $cdWin = [System.Windows.Markup.XamlReader]::Load($cdReader)
    $lblCD = $cdWin.FindName("lblCD")
    $pbCD = $cdWin.FindName("pbCD")
    $btnCancelRestart = $cdWin.FindName("btnCancelRestart")

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromSeconds(1)
    $script:secondsLeft = 25

    $timer.Add_Tick({
        $script:secondsLeft--
        $lblCD.Text = "Reiniciando em $($script:secondsLeft) segundos..."
        $pbCD.Value = $script:secondsLeft
        if ($script:secondsLeft -le 0) {
            $timer.Stop()
            $cdWin.Close()
            shutdown.exe /r /t 0 /f
        }
    })

    $btnCancelRestart.Add_Click({
        $timer.Stop()
        $cdWin.Close()
        Show-YellowAlertWindow
    })

    $timer.Start()
    $cdWin.ShowDialog() | Out-Null
}

# SEGUNDO BALAO: QUANDO O USUARIO OPTOU POR CONTINUAR SEM REINICIAR
function Show-YellowAlertWindow {
    $yellowXaml = @'
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            Title="Aviso de Reinicializacao" Width="530" Height="230"
            WindowStartupLocation="CenterScreen" Background="Transparent"
            AllowsTransparency="True" WindowStyle="None"
            Topmost="True" ResizeMode="NoResize">

        <Border Background="#FFDE00" CornerRadius="16" BorderBrush="#FF6600" BorderThickness="4" Padding="20,16" Margin="10">
            <Border.Effect>
                <DropShadowEffect Color="#000000" BlurRadius="22" ShadowDepth="4" Opacity="0.65"/>
            </Border.Effect>

            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <StackPanel Grid.Row="0" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,0,0,8">
                    <Grid Width="30" Height="30" Margin="0,0,10,0" VerticalAlignment="Center">
                        <Ellipse Fill="#DC2626"/>
                        <TextBlock Text="!" FontSize="20" FontWeight="Black" Foreground="#FFFFFF" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="0,-2,0,0"/>
                    </Grid>
                    <TextBlock Text="VOCE OPTOU POR CONTINUAR SEM REINICIAR!!" FontSize="13.5" FontWeight="Black" Foreground="#000000" VerticalAlignment="Center"/>
                </StackPanel>

                <TextBlock Grid.Row="1" Text="As mudancas e otimizacoes so entrarao em vigor apos reiniciar o seu PC." 
                       FontSize="13" FontWeight="Bold" Foreground="#000000" TextWrapping="Wrap" TextAlignment="Center" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="10,0,10,12"/>

                <Button x:Name="btnOkYellow" Grid.Row="2" Content="ESTOU CIENTE (OK)" Background="#000000" Foreground="#FFDE00" FontSize="12.5" FontWeight="Black" Height="36" Cursor="Hand" BorderThickness="0">
                    <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="6"/></Style></Button.Resources>
                </Button>
            </Grid>
        </Border>
    </Window>
'@
    $yReader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($yellowXaml))
    $yWin = [System.Windows.Markup.XamlReader]::Load($yReader)
    $btnOkYellow = $yWin.FindName("btnOkYellow")
    $btnOkYellow.Add_Click({ $yWin.Close() })
    $yWin.ShowDialog() | Out-Null
}

# PRIMEIRO BALAO PULSANTE
function Show-PulsingYellowPrompt {
    $pXaml = @'
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            Title="Otimizacao Concluida" Width="550" Height="200"
            WindowStartupLocation="CenterScreen" Background="Transparent"
            AllowsTransparency="True" WindowStyle="None"
            Topmost="True" ShowInTaskbar="False" ResizeMode="NoResize">

        <Border x:Name="pulseBorder" Background="#FFDE00" CornerRadius="16" BorderBrush="#FF6600" BorderThickness="4" Padding="20,16" Margin="10">
            <Border.RenderTransform>
                <ScaleTransform x:Name="pulseScale" CenterX="265" CenterY="90"/>
            </Border.RenderTransform>
            <Border.Triggers>
                <EventTrigger RoutedEvent="Border.Loaded">
                    <BeginStoryboard>
                        <Storyboard RepeatBehavior="Forever" AutoReverse="True">
                            <DoubleAnimation Storyboard.TargetName="pulseScale" 
                                             Storyboard.TargetProperty="ScaleX" 
                                             From="1.0" To="1.03" Duration="0:0:0.65"/>
                            <DoubleAnimation Storyboard.TargetName="pulseScale" 
                                             Storyboard.TargetProperty="ScaleY" 
                                             From="1.0" To="1.03" Duration="0:0:0.65"/>
                            <DoubleAnimation Storyboard.TargetName="pulseBorder" 
                                             Storyboard.TargetProperty="Opacity" 
                                             From="1.0" To="0.90" Duration="0:0:0.65"/>
                        </Storyboard>
                    </BeginStoryboard>
                </EventTrigger>
            </Border.Triggers>
            <Border.Effect>
                <DropShadowEffect Color="#000000" BlurRadius="24" ShadowDepth="4" Opacity="0.65"/>
            </Border.Effect>

            <Grid VerticalAlignment="Center">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <StackPanel Grid.Row="0" Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="0,0,0,8">
                    <Grid Width="34" Height="34" Margin="0,0,12,0" VerticalAlignment="Center">
                        <Ellipse Fill="#DC2626"/>
                        <TextBlock Text="!" FontSize="24" FontWeight="Black" Foreground="#FFFFFF" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="0,-2,0,0"/>
                    </Grid>
                    <TextBlock Text="OTIMIZACAO CONCLUIDA COM SUCESSO!!" FontSize="14.5" FontWeight="Black" Foreground="#000000" VerticalAlignment="Center"/>
                </StackPanel>

                <TextBlock Grid.Row="1" Text="Para que as mudancas sejam aplicadas, favor reiniciar o seu PC!!" 
                           FontSize="13.5" FontWeight="Black" Foreground="#000000" TextWrapping="Wrap" TextAlignment="Center" HorizontalAlignment="Center" Margin="10,0,10,8"/>

                <TextBlock Grid.Row="2" Text="[ Utilize os botoes SIM ou NAO no card do rodape para prosseguir ]" 
                           FontSize="11" FontWeight="Bold" Foreground="#663E00" HorizontalAlignment="Center"/>
            </Grid>
        </Border>
    </Window>
'@
    $pReader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($pXaml))
    $pWin = [System.Windows.Markup.XamlReader]::Load($pReader)

    if ($Script:PulsingWindow -and $Script:PulsingWindow.IsVisible) {
        $Script:PulsingWindow.Close()
    }
    $Script:PulsingWindow = $pWin

    $pWin.Show()
}

# -----------------------------------------------------------------------------------------------------------------
# 4. GERADOR DO CATALOGO DA LOJA DE PROGRAMAS WINUTIL
# -----------------------------------------------------------------------------------------------------------------
$Script:CatalogCheckboxes = @{}

function Render-Catalog {
    if ($spCategoryCards.Children.Count -gt 0) { return }
    $categories = $Script:WinUtilCatalog | Group-Object Category

    foreach ($cat in $categories) {
        $cardBorder = New-Object System.Windows.Controls.Border
        $cardBorder.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0C1322")
        $cardBorder.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E2E4A")
        $cardBorder.BorderThickness = [System.Windows.Thickness]::new(1)
        $cardBorder.CornerRadius = [System.Windows.CornerRadius]::new(6)
        $cardBorder.Padding = [System.Windows.Thickness]::new(10, 8, 10, 8)
        $cardBorder.Margin = [System.Windows.Thickness]::new(0, 0, 0, 8)

        $catStack = New-Object System.Windows.Controls.StackPanel

        $title = New-Object System.Windows.Controls.TextBlock
        $title.Text = "[ $($cat.Name.ToUpper()) ]"
        $title.FontWeight = [System.Windows.FontWeights]::Black
        $title.FontSize = 12
        $title.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#38BDF8")
        $title.Margin = [System.Windows.Thickness]::new(0, 0, 0, 6)
        $catStack.Children.Add($title) | Out-Null

        $wrap = New-Object System.Windows.Controls.WrapPanel
        $wrap.Orientation = [System.Windows.Controls.Orientation]::Horizontal

        foreach ($app in $cat.Group) {
            $cb = New-Object System.Windows.Controls.CheckBox
            $cb.Content = $app.Name
            $cb.Tag = $app.Id
            $cb.Style = $window.Resources["ToggleSwitch"]
            $cb.Width = 260
            $cb.Margin = [System.Windows.Thickness]::new(0, 2, 10, 2)
            $cb.Add_Checked({ Update-SelectedAppsCount })
            $cb.Add_Unchecked({ Update-SelectedAppsCount })

            $Script:CatalogCheckboxes[$app.Id] = $cb
            $wrap.Children.Add($cb) | Out-Null
        }

        $catStack.Children.Add($wrap) | Out-Null
        $cardBorder.Child = $catStack
        $spCategoryCards.Children.Add($cardBorder) | Out-Null
    }
}

function Update-SelectedAppsCount {
    $selCount = ($Script:CatalogCheckboxes.Values | Where-Object { $_.IsChecked }).Count
    $lblSelectedCount.Text = " ($selCount selecionados)"
}

# -----------------------------------------------------------------------------------------------------------------
# 5. CONTROLES DE NAVEGACAO ENTRE ABAS
# -----------------------------------------------------------------------------------------------------------------
$btnNavOtimizacao.Add_Click({
    $viewOtimizacao.Visibility = [System.Windows.Visibility]::Visible
    $viewProgramas.Visibility = [System.Windows.Visibility]::Collapsed
    $btnNavOtimizacao.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0284C7")
    $btnNavOtimizacao.Foreground = [System.Windows.Media.Brushes]::White
    $btnNavProgramas.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
    $btnNavProgramas.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
})

$btnNavProgramas.Add_Click({
    $viewOtimizacao.Visibility = [System.Windows.Visibility]::Collapsed
    $viewProgramas.Visibility = [System.Windows.Visibility]::Visible
    $btnNavProgramas.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0284C7")
    $btnNavProgramas.Foreground = [System.Windows.Media.Brushes]::White
    $btnNavOtimizacao.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
    $btnNavOtimizacao.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
    Render-Catalog
})

$btnSelectAllCatalog.Add_Click({
    $Script:CatalogCheckboxes.Values | ForEach-Object { $_.IsChecked = $true }
})

$btnClearCatalog.Add_Click({
    $Script:CatalogCheckboxes.Values | ForEach-Object { $_.IsChecked = $false }
})

$txtSearchApp.Add_TextChanged({
    $query = $txtSearchApp.Text.Trim().ToLower()
    foreach ($kv in $Script:CatalogCheckboxes.GetEnumerator()) {
        $cb = $kv.Value
        if ([string]::IsNullOrWhiteSpace($query) -or $cb.Content.ToString().ToLower().Contains($query)) {
            $cb.Visibility = [System.Windows.Visibility]::Visible
        } else {
            $cb.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }
})

$btnInstallSelectedApps.Add_Click({
    $selected = $Script:CatalogCheckboxes.Values | Where-Object { $_.IsChecked }
    if ($selected.Count -eq 0) {
        [System.Windows.MessageBox]::Show("Nenhum aplicativo foi selecionado.", "Aviso", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        return
    }
    $btnInstallSelectedApps.IsEnabled = $false
    $total = $selected.Count
    $i = 0
    foreach ($appCb in $selected) {
        $i++
        $appId = $appCb.Tag
        $appName = $appCb.Content
        Update-UI "Instalando $appName ($i de $total)..." ([math]::Round(($i / $total) * 100))
        if ($appId -like "msstore:*") {
            $storeId = $appId -replace "msstore:", ""
            Start-Process "winget" -ArgumentList "install --id $storeId --source msstore --accept-source-agreements --accept-package-agreements --silent" -WindowStyle Hidden -Wait
        } else {
            Start-Process "winget" -ArgumentList "install --id $appId -e --accept-source-agreements --accept-package-agreements --silent" -WindowStyle Hidden -Wait
        }
    }
    Update-UI "Instalacao de programas concluida!" 100
    $btnInstallSelectedApps.IsEnabled = $true
})

# -----------------------------------------------------------------------------------------------------------------
# 6. INICIALIZACAO DE HARDWARE
# -----------------------------------------------------------------------------------------------------------------
$window.Add_Loaded({
    try {
        $ifeo = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
        foreach ($exe in @("updater.exe", "GoogleUpdate.exe", "GoogleCrashHandler.exe", "GoogleCrashHandler64.exe")) {
            Remove-Item -Path "$ifeo\$exe" -Recurse -Force -ErrorAction SilentlyContinue
        }

        $cpu = (Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue).Name
        $lblCPU.Text = if ($cpu) { $cpu.Trim() } else { "Intel / AMD" }

        $mb = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue
        $lblMotherboard.Text = if ($mb) { "$($mb.Manufacturer) $($mb.Product)".Trim() } else { "Generica" }

        $gpu = (Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1).Name
        $lblGPU.Text = if ($gpu) { $gpu.Trim() } else { "Video Integrado / Dedicado" }

        $ram = [math]::Round((Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue).TotalPhysicalMemory / 1GB)
        $freeRam = [math]::Round((Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).FreePhysicalMemory / (1024 * 1024), 1)
        $lblRAM.Text = "$freeRam GB Livre / $ram GB"

        $totalDiskGB = [math]::Round(((Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue | Measure-Object -Property Size -Sum).Sum / 1GB))
        if ($totalDiskGB -ge 1024) {
            $lblDisk.Text = "$([math]::Round($totalDiskGB / 1024, 2)) TB"
        } else {
            $lblDisk.Text = "$totalDiskGB GB"
        }

        $procCount = (Get-Process).Count
        $res = "$([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width)x$([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height)"
        $lblProcRes.Text = "$procCount proc | $res"
    } catch {}
})

# -----------------------------------------------------------------------------------------------------------------
# 7. PONTO DE RESTAURACAO OBRIGATORIO
# -----------------------------------------------------------------------------------------------------------------
$btnCriarRestore.Add_Click({
    $btnCriarRestore.IsEnabled = $false
    Update-UI "Inicializando servico de protecao do sistema..." 5
    try {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore' -Name 'SystemRestorePointCreationFrequency' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        for ($p = 10; $p -le 70; $p += 15) {
            Update-UI "Criando Ponto de Restauracao do Windows... ($p%)" $p
            Start-Sleep -Milliseconds 90
        }
        
        Update-UI "Gravando backup de seguranca no disco... (85%)" 85
        $ts = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        Checkpoint-Computer -Description "WinDebloat_Backup_$ts" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        
        Update-UI "Ponto de Restauracao criado com sucesso! (100%)" 100
        Start-Sleep -Milliseconds 200
        
        $lblRestoreTitle.Text = "PONTO DE RESTAURACAO CRIADO"
        $lblRestoreTitle.Foreground = [System.Windows.Media.Brushes]::LimeGreen
        $lblRestoreStatus.Text = "Sistema Protegido - [ 100% Destravado ]"
        $lblRestoreStatus.Foreground = [System.Windows.Media.Brushes]::LimeGreen
        
        $viewOtimizacao.IsEnabled = $true
        $viewProgramas.IsEnabled = $true
        $btnNavProgramas.IsEnabled = $true
        $btnRun.IsEnabled = $true
        $btnInstantGamerClean.IsEnabled = $true
        $btnPresetPadrao.IsEnabled = $true
        $btnPresetRecomendado.IsEnabled = $true
        $btnPresetMaximo.IsEnabled = $true
        $btnDesmarcarTudo.IsEnabled = $true
        $btnRestartSim.IsEnabled = $true
        $btnRestartNao.IsEnabled = $true
        
        $lblStatus.Foreground = [System.Windows.Media.Brushes]::LimeGreen
        Update-UI "Sistema 100% destravado! Escolha as otimizacoes ou instale programas a vontade." 0
    } catch {
        $lblRestoreStatus.Text = "Protecao Inativa - [ Destravado ]"
        $lblRestoreStatus.Foreground = [System.Windows.Media.Brushes]::Orange
        
        $viewOtimizacao.IsEnabled = $true
        $viewProgramas.IsEnabled = $true
        $btnNavProgramas.IsEnabled = $true
        $btnRun.IsEnabled = $true
        $btnInstantGamerClean.IsEnabled = $true
        $btnPresetPadrao.IsEnabled = $true
        $btnPresetRecomendado.IsEnabled = $true
        $btnPresetMaximo.IsEnabled = $true
        $btnDesmarcarTudo.IsEnabled = $true
        $btnRestartSim.IsEnabled = $true
        $btnRestartNao.IsEnabled = $true
        
        Update-UI "Sistema destravado. Pode aplicar as otimizacoes." 0
    }
})

# LIMPAR RAM
$btnInstantGamerClean.Add_Click({
    Update-UI "Limpando memoria RAM e encerrando WebView2 e Google Updater..." 30
    
    $ifeo = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
    foreach ($exe in @("updater.exe", "GoogleUpdate.exe", "GoogleCrashHandler.exe", "GoogleCrashHandler64.exe")) {
        Remove-Item -Path "$ifeo\$exe" -Recurse -Force -ErrorAction SilentlyContinue
    }

    Stop-Process -Name "msedgewebview2", "updater", "GoogleUpdate", "GoogleCrashHandler*" -Force -ErrorAction SilentlyContinue
    Get-Process | ForEach-Object {
        try { [Win32.Win32API]::EmptyWorkingSet($_.Handle) | Out-Null } catch {}
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Update-UI "Memoria RAM liberada e processos pesados encerrados!" 100
})

# Presets
$btnDesmarcarTudo.Add_Click({
    $allCheckboxes = @(
        $chkRemoveApps, $chkRemoveGamingApps, $chkRemoveCommApps, $chkRemoveW11Outlook, $chkRemoveDevApps, $chkForceRemoveEdge, $chkUninstallOneDrive,
        $chkDisableTelemetry, $chkDisableBing, $chkDisableSuggestions, $chkDisableLockscreenTips, $chkDisableCopilot, $chkDisableRecall, $chkDisableDefenderFull,
        $chkDisableWer, $chkDisableSensors, $chkDisableRetailDemo, $chkDisableNearbyShare,
        $chkGameHAGS, $chkGameMMCSS, $chkGameCpuPriority, $chkGameNetworkLatency, $chkGameDvr, $chkGameTimerRes, $chkGameVisualFX,
        $chkTaskbarAlignLeft, $chkHideSearchTb, $chkHideTaskview, $chkDisableWidgets, $chkHideChat, $chkClearStart, $chkDisableDVR,
        $chkNetThrottling, $chkDisableTeredo, $chkPrioritizeNetwork,
        $chkShowKnownFileExt, $chkShowHiddenFolders, $chkHideHome, $chkHideGallery, $chkHideDupliDrive, $chkHide3dObjects, $chkRevertContextMenu,
        $chkHideIncludeInLibrary, $chkHideGiveAccessTo, $chkHideShare,
        $chkCleanTemp, $chkFlushDNS, $chkCleanWinUpdate, $chkDisableFastStartup, $chkPowerUltimate, $chkDisableUSBThrottling, $chkRepairSFC
    )
    foreach ($chk in $allCheckboxes) { $chk.IsChecked = $false }
    Update-UI "Todas as opcoes foram desmarcadas." 0
})

$btnPresetPadrao.Add_Click({
    $btnDesmarcarTudo.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
    $chkRemoveApps.IsChecked = $true
    $chkDisableTelemetry.IsChecked = $true
    $chkDisableBing.IsChecked = $true
    $chkDisableLockscreenTips.IsChecked = $true
    $chkDisableSuggestions.IsChecked = $true
    $chkShowKnownFileExt.IsChecked = $true
    $chkDisableWidgets.IsChecked = $true
    $chkHideChat.IsChecked = $true
    $chkDisableCopilot.IsChecked = $true
    $chkCleanTemp.IsChecked = $true
    $chkFlushDNS.IsChecked = $true
    Update-UI "Predefinicao Padrao carregada." 0
})

$btnPresetRecomendado.Add_Click({
    $btnPresetPadrao.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
    $chkDisableDVR.IsChecked = $true
    $chkRevertContextMenu.IsChecked = $false
    $chkHideDupliDrive.IsChecked = $true
    $chkHide3dObjects.IsChecked = $true
    $chkUninstallOneDrive.IsChecked = $true
    $chkDisableFastStartup.IsChecked = $true
    $chkPowerUltimate.IsChecked = $true
    $chkNetThrottling.IsChecked = $true
    Update-UI "Predefinicao Recomendada carregada." 0
})

$btnPresetMaximo.Add_Click({
    $btnPresetRecomendado.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
    $chkRemoveGamingApps.IsChecked = $true
    $chkRemoveCommApps.IsChecked = $true
    $chkRemoveW11Outlook.IsChecked = $true
    $chkRemoveDevApps.IsChecked = $true
    $chkDisableRecall.IsChecked = $true
    $chkDisableDefenderFull.IsChecked = $true
    $chkGameHAGS.IsChecked = $true
    $chkGameMMCSS.IsChecked = $true
    $chkGameCpuPriority.IsChecked = $true
    $chkGameNetworkLatency.IsChecked = $true
    $chkGameDvr.IsChecked = $true
    $chkDisableUSBThrottling.IsChecked = $true
    $chkDisableWer.IsChecked = $true
    $chkDisableSensors.IsChecked = $true
    Update-UI "Predefinicao Ativar Modo Gamer carregada." 0
})

# -----------------------------------------------------------------------------------------------------------------
# 8. EXECUÇÃO DAS AÇÕES DE OTIMIZAÇÃO
# -----------------------------------------------------------------------------------------------------------------
$btnRun.Add_Click({
    $btnRun.IsEnabled = $false
    Update-UI "Iniciando otimizacao do sistema..." 5

    # 1. Apps
    if ($chkRemoveApps.IsChecked) {
        $count = 0
        foreach ($app in $Script:DefaultBloatware) {
            $count++
            $pct = [math]::Round(($count / $Script:DefaultBloatware.Count) * 15)
            Update-UI "Removendo bloatware: $app..." (5 + $pct)
            Get-AppxPackage -Name "*$app*" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "*$app*" } | Remove-ProvisionedAppxPackage -Online -AllUsers -ErrorAction SilentlyContinue
        }
    }

    if ($chkRemoveGamingApps.IsChecked) {
        Update-UI "Removendo apps Xbox..." 22
        Get-AppxPackage -Name "*Microsoft.GamingApp*", "*Microsoft.XboxGameOverlay*", "*Microsoft.XboxGamingOverlay*" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    }

    if ($chkRemoveCommApps.IsChecked) {
        Update-UI "Removendo Email e Calendario..." 25
        Get-AppxPackage -Name "*Microsoft.windowscommunicationsapps*", "*Microsoft.People*" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    }

    if ($chkRemoveW11Outlook.IsChecked) {
        Update-UI "Removendo Novo Outlook..." 28
        Get-AppxPackage -Name "*Microsoft.OutlookForWindows*" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    }

    if ($chkRemoveDevApps.IsChecked) {
        Update-UI "Removendo apps Dev..." 30
        Get-AppxPackage -Name "*Microsoft.PowerAutomateDesktop*", "*Microsoft.RemoteDesktop*", "*Windows.DevHome*" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    }

    if ($chkForceRemoveEdge.IsChecked) {
        Update-UI "Forcando desinstalacao do Microsoft Edge..." 35
        try {
            $regView = [Microsoft.Win32.RegistryView]::Registry32
            $hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $regView)
            $hklm.CreateSubKey('SOFTWARE\Microsoft\EdgeUpdateDev').SetValue('AllowUninstall', '')
            $uninstallRegKey = $hklm.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge')
            if ($null -ne $uninstallRegKey) {
                $uninstallString = $uninstallRegKey.GetValue('UninstallString') + ' --force-uninstall'
                Start-Process cmd.exe "/c $uninstallString" -WindowStyle Hidden -Wait
            }
        } catch {}
    }

    if ($chkUninstallOneDrive.IsChecked) {
        Update-UI "Desinstalando e bloqueando OneDrive..." 40
        Stop-Process -Name OneDrive, FileCoAuth -Force -ErrorAction SilentlyContinue
        Start-Process (Join-Path $Env:SystemRoot "System32\OneDriveSetup.exe") -ArgumentList "/uninstall" -Wait -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    }

    # 2. PRIVACIDADE E BLOQUEIO SILENCIOSO DO GOOGLE UPDATER
    if ($chkDisableTelemetry.IsChecked) {
        Update-UI "Desativando Telemetria e Bloqueando Google Updater..." 45
        
        $ifeo = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
        foreach ($exe in @("updater.exe", "GoogleUpdate.exe", "GoogleCrashHandler.exe", "GoogleCrashHandler64.exe")) {
            Remove-Item -Path "$ifeo\$exe" -Recurse -Force -ErrorAction SilentlyContinue
        }

        $gPol = "HKLM:\SOFTWARE\Policies\Google\Update"
        if (-not (Test-Path $gPol)) { New-Item -Path $gPol -Force | Out-Null }
        Set-ItemProperty -Path $gPol -Name "AutoUpdateCheckPeriodMinutes" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gPol -Name "UpdateDefault" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gPol -Name "DisableAutoUpdateChecksCheckboxValue" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gPol -Name "InstallDefault" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gPol -Name "Update{8A69D345-D564-463C-AFF1-A69D9E530F96}" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue

        Get-Service -Name "*gupdate*", "*GoogleUpdater*", "*gupdatem*", "*Google*" -ErrorAction SilentlyContinue | ForEach-Object {
            Stop-Service -Name $_.Name -Force -ErrorAction SilentlyContinue
            Set-Service -Name $_.Name -StartupType Disabled -ErrorAction SilentlyContinue
        }

        Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { ($_.TaskName -like "*Google*") -or ($_.TaskPath -like "*Google*") } | ForEach-Object {
            Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue | Out-Null
            Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
        }

        $googleDirs = @(
            "$env:ProgramFiles (x86)\Google\GoogleUpdater",
            "$env:ProgramFiles\Google\GoogleUpdater",
            "$env:LOCALAPPDATA\Google\GoogleUpdater",
            "$env:ProgramFiles (x86)\Google\Update",
            "$env:ProgramFiles\Google\Update"
        )
        foreach ($dir in $googleDirs) {
            if (Test-Path $dir) {
                Get-ChildItem -Path $dir -Include "updater.exe", "GoogleUpdate.exe" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                    icacls $_.FullName /deny "*S-1-1-0:(X)" | Out-Null
                }
            }
        }

        Stop-Process -Name "updater", "GoogleUpdate", "GoogleCrashHandler", "GoogleCrashHandler64" -Force -ErrorAction SilentlyContinue
        
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        "DiagTrack", "InventorySvc", "whesvc", "DPS", "PcaSvc", "TrkWks" | ForEach-Object {
            Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue
            Set-Service -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue
        }
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsRunInBackground" -Type DWord -Value 2 -Force -ErrorAction SilentlyContinue
    }

    # 3. EXTERMINIO DO WEBVIEW2 NO WINDOWS SEARCH
    if ($chkDisableBing.IsChecked) {
        Update-UI "Exterminando WebView2 do Windows Search (Pesquisa 100% Local)..." 50
        
        $fmOverride = "HKLM:\SYSTEM\CurrentControlSet\Control\FeatureManagement\Overrides\8\1694661260"
        if (-not (Test-Path $fmOverride)) { New-Item -Path $fmOverride -Force | Out-Null }
        Set-ItemProperty -Path $fmOverride -Name "EnabledState" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $fmOverride -Name "EnabledStateOptions" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $fmOverride -Name "Variant" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $fmOverride -Name "VariantPayload" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $fmOverride -Name "VariantPayloadKind" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue

        $cs1Override = "HKLM:\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\1694661260"
        if (-not (Test-Path $cs1Override)) { New-Item -Path $cs1Override -Force | Out-Null }
        Set-ItemProperty -Path $cs1Override -Name "EnabledState" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue

        $wsPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        if (-not (Test-Path $wsPolicy)) { New-Item -Path $wsPolicy -Force | Out-Null }
        Set-ItemProperty -Path $wsPolicy -Name "EnableDynamicContentInWSB" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $wsPolicy -Name "DisableWebSearch" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $wsPolicy -Name "ConnectedSearchUseWeb" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $wsPolicy -Name "ConnectedSearchUseWebOverMeteredConnections" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $wsPolicy -Name "AllowSearchToUseLocation" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $wsPolicy -Name "AllowCortana" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsMSA_Searched" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDeviceSearchHistoryEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsAAD_Searched" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue

        $edgePol = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
        if (-not (Test-Path $edgePol)) { New-Item -Path $edgePol -Force | Out-Null }
        Set-ItemProperty -Path $edgePol -Name "StartupBoostEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $edgePol -Name "BackgroundModeEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $edgePol -Name "WebWidgetAllowed" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue

        Stop-Process -Name "msedgewebview2" -Force -ErrorAction SilentlyContinue
        Stop-Process -Name "SearchHost" -Force -ErrorAction SilentlyContinue
    }

    if ($chkDisableSuggestions.IsChecked) {
        Update-UI "Desativando Sugestoes e Anuncios..." 55
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    }

    if ($chkDisableLockscreenTips.IsChecked) {
        Update-UI "Desativando Dicas na Tela de Bloqueio..." 58
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    }

    if ($chkDisableCopilot.IsChecked) {
        Update-UI "Desativando Copilot e IA em segundo plano..." 60
        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        Stop-Service -Name "WSAIFabricSvc" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "WSAIFabricSvc" -StartupType Disabled -ErrorAction SilentlyContinue
    }

    if ($chkDisableRecall.IsChecked) {
        Update-UI "Desativando Recall..." 63
        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    }

    # 4. Defender
    if ($chkDisableDefenderFull.IsChecked) {
        Update-UI "Desativando Defender e Smart App Control..." 66
        if (-not (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy")) { New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Force | Out-Null }
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Name "VerifiedAndReputablePolicyState" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "Off" -Type String -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        $defPolicies = @(
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender",
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection",
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet",
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications"
        )
        foreach ($dp in $defPolicies) { if (-not (Test-Path $dp)) { New-Item -Path $dp -Force | Out-Null } }
        
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableRealtimeMonitoring" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableBehaviorMonitoring" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableOnAccessProtection" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableScanOnRealtimeEnable" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue

        Get-ChildItem -Path "$env:USERPROFILE\Downloads", "C:\", "D:\", "H:\" -Filter "*.exe" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue
        Stop-Process -Name smartscreen -Force -ErrorAction SilentlyContinue
    }

    # 5. Servicos
    if ($chkDisableWer.IsChecked) { Stop-Service -Name "WerSvc" -Force -ErrorAction SilentlyContinue; Set-Service -Name "WerSvc" -StartupType Disabled -ErrorAction SilentlyContinue }
    if ($chkDisableSensors.IsChecked) { 
        "SensorService", "SensrSvc", "MapsBroker", "lfsvc" | ForEach-Object {
            Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue
            Set-Service -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue
        }
    }
    if ($chkDisableRetailDemo.IsChecked) { Stop-Service -Name "RetailDemo" -Force -ErrorAction SilentlyContinue; Set-Service -Name "RetailDemo" -StartupType Disabled -ErrorAction SilentlyContinue }
    if ($chkDisableNearbyShare.IsChecked) { 
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" -Name "CdpSessionUserAuthzPolicy" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Stop-Service -Name "CDPSvc" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "CDPSvc" -StartupType Disabled -ErrorAction SilentlyContinue
    }

    # 6. Turbo Gamer
    if ($chkGameHAGS.IsChecked) { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Type DWord -Value 2 -Force -ErrorAction SilentlyContinue }
    if ($chkGameMMCSS.IsChecked) { Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Type DWord -Value 8 -Force -ErrorAction SilentlyContinue }
    if ($chkGameCpuPriority.IsChecked) { 
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Type DWord -Value 38 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value 0xFFFFFFFF -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MicrosoftEdgeAutoLaunch_*" -ErrorAction SilentlyContinue
    }
    if ($chkGameNetworkLatency.IsChecked) {
        $adapters = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -ErrorAction SilentlyContinue
        foreach ($ad in $adapters) {
            Set-ItemProperty -Path $ad.PSPath -Name "TcpAckFrequency" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $ad.PSPath -Name "TCPNoDelay" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        }
    }
    if ($chkGameDvr.IsChecked) {
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    }

    # 7. Rede
    if ($chkNetThrottling.IsChecked) { Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xFFFFFFFF -Force -ErrorAction SilentlyContinue }
    if ($chkDisableTeredo.IsChecked) { netsh interface teredo set state disabled *>$null }
    if ($chkPrioritizeNetwork.IsChecked) { Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue }

    # 8. Barra e Iniciar
    if ($chkTaskbarAlignLeft.IsChecked) { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue }
    if ($chkHideSearchTb.IsChecked) { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue }
    if ($chkHideTaskview.IsChecked) { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue }
    if ($chkDisableWidgets.IsChecked) { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue }
    if ($chkHideChat.IsChecked) { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue }

    # 9. Explorador
    if ($chkShowKnownFileExt.IsChecked) { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue }
    if ($chkShowHiddenFolders.IsChecked) { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue }
    if ($chkHideDupliDrive.IsChecked) { Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-426E-A348-B9D4E0F00740}" -Recurse -Force -ErrorAction SilentlyContinue }
    if ($chkHideHome.IsChecked) { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue }
    if ($chkHide3dObjects.IsChecked) { Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -Force -ErrorAction SilentlyContinue }
    if ($chkRevertContextMenu.IsChecked) {
        Update-UI "Restaurando Menu Classico do Botao Direito..." 80
        New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Value "" -Force -ErrorAction SilentlyContinue | Out-Null
    }

    # 10. Limpeza
    if ($chkCleanTemp.IsChecked) {
        Update-UI "Limpando arquivos temporarios e prefetch..." 85
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SystemRoot\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
    }

    if ($chkFlushDNS.IsChecked) {
        Update-UI "Limpando cache de DNS e icones..." 90
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:LocalAppData\IconCache.db" -Force -ErrorAction SilentlyContinue
    }

    if ($chkCleanWinUpdate.IsChecked) {
        Update-UI "Limpando componentes antigos do Windows Update..." 92
        Start-Process -FilePath "dism.exe" -ArgumentList "/online /cleanup-image /startcomponentcleanup /resetbase" -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue
    }

    if ($chkDisableFastStartup.IsChecked) {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    }

    if ($chkPowerUltimate.IsChecked) {
        try {
            $guid = (powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null | Select-String -Pattern '[A-Fa-f0-9-]{36}').Matches.Value
            if ($guid) { powercfg /setactive $guid }
        } catch {}
    }

    if ($chkDisableUSBThrottling.IsChecked) {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB" -Name "DisableSelectiveSuspend" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    }

    if ($chkRepairSFC.IsChecked) {
        Update-UI "Executando reparo de integridade (SFC)..." 94
        Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue
    }

    # Reinicia o Explorer
    Update-UI "Reiniciando Windows Explorer..." 97
    Stop-Process -Name Explorer -Force -ErrorAction SilentlyContinue

    Update-UI "Otimizacao Concluida com Sucesso!" 100

    # 1. LIBERA AS ABAS PARA NAVEGACAO LIVRE
    $btnNavProgramas.IsEnabled = $true
    $viewProgramas.IsEnabled = $true
    $btnNavOtimizacao.IsEnabled = $true
    $viewOtimizacao.IsEnabled = $true

    # 2. MANTEM OS BOTOES SIM E NAO ATIVOS NO RODAPE
    $btnRestartSim.IsEnabled = $true
    $btnRestartNao.IsEnabled = $true
    $btnRun.IsEnabled = $false

    # 3. DISPARA O BALAO COM BORDA LARANJA ACENTUADA E PONTAS ARREDONDADAS
    Show-PulsingYellowPrompt
})

# -----------------------------------------------------------------------------------------------------------------
# 9. EVENTOS DOS BOTOES DO RODAPE (CONTROLAM OS BALOES)
# -----------------------------------------------------------------------------------------------------------------
$btnRestartSim.Add_Click({
    if ($Script:PulsingWindow -and $Script:PulsingWindow.IsVisible) {
        $Script:PulsingWindow.Close()
    }
    Show-CountdownWindow
})

$btnRestartNao.Add_Click({
    if ($Script:PulsingWindow -and $Script:PulsingWindow.IsVisible) {
        $Script:PulsingWindow.Close()
    }
    Show-YellowAlertWindow
})

# Fecha o balao flutuante se a janela principal for fechada
$window.Add_Closing({
    if ($Script:PulsingWindow -and $Script:PulsingWindow.IsVisible) {
        $Script:PulsingWindow.Close()
    }
})

# Exibe a janela principal
$window.ShowDialog() | Out-Null