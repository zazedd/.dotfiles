{
  applications = {
    finder = {
      menuBar = {
        view = {
          showPathBar = true;
          showSidebar = false;
          showStatusBar = false;
        };
      };
      settings = {
        advanced = {
          showAllFilenameExtensions = true;
        };
        general = {
          showTheseItemsOnTheDesktop = {
            cdsDvdsAndiPods = true;
            externalDisks = true;
            hardDisks = false;
          };
        };
      };
    };
    systemSettings = {
      accessibility = {
        audio = {
          backgroundSounds = false;
          backgroundSoundsOptions = {
            timer = false;
          };
        };
        hoverText = {
          hoverTypingOptions = {
            textFont = "Default";
          };
          options = {
            textFont = "Default";
          };
        };
        keyboard = {
          slowKeys = false;
          slowKeysOptions = {
            acceptanceDelay = 250;
          };
          stickyKeys = false;
          stickyKeysOptions = {
            pressTheShiftKeyFiveTimesToToggleStickyKeys = false;
          };
        };
        liveCaptions = {
          fontFamily = "Default";
        };
        liveSpeech = {
          liveSpeech = false;
        };
        pointerControl = {
          ignoreBuiltInTrackpadWhenMouseOrWirelessTrackpadIsPresent = false;
          mouseKeys = false;
          springLoading = true;
          springLoadingSpeed = 0.5;
          trackpadOptions = {
            dragging = "Off";
            useInertiaWhenScrolling = true;
            useTrackpadForScrolling = true;
          };
        };
        readAndSpeak = {
          typingFeedback = {
            characters = true;
            modifierKeys = false;
            selectionChanges = false;
            words = true;
          };
        };
        rtt = {
          sendImmediately = true;
        };
        voiceControl = {
          microphone = "AppleUSBAudioEngine:Sony Interactive Entertainment:Wireless Controller:110000:2";
        };
        voiceOver = {
          voiceOver = false;
        };
        zoom = {
          useKeyboardShortcutsToZoom = false;
        };
      };
      appleIntelligenceAndSiri = {
        siri = {
          enable = false;
        };
      };
      desktopAndDock = {
        desktopAndStageManager = {
          showItems = {
            inStageManager = false;
          };
          showRecentAppsInStageManager = true;
          showWindowsFromAnApplication = "All at Once";
        };
        dock = {
          animateOpeningApplications = true;
          automaticallyHideAndShowTheDock = {
            delay = 0.25;
            enabled = true;
          };
          dockPositionOnScreen = "Right";
          minimizedWindowAnimation = "Scale Effect";
          showSuggestedAndRecentAppsInDock = false;
          size = 48;
        };
        hotCorners = {
          bottomLeft = {
            modifiers = {
              command = false;
              control = false;
              option = false;
              shift = false;
            };
          };
          bottomRight = {
            action = "Quick Note";
            modifiers = {
              command = false;
              control = false;
              option = false;
              shift = false;
            };
          };
          topLeft = {
            action = "Mission Control";
            modifiers = {
              command = false;
              control = false;
              option = false;
              shift = false;
            };
          };
          topRight = {
            modifiers = {
              command = false;
              control = false;
              option = false;
              shift = false;
            };
          };
        };
        missionControl = {
          displaysHaveSeparateSpaces = false;
          shortcuts = {
            applicationWindows = "-";
            missionControl = "-";
            showDesktop = "-";
          };
        };
        widgets = {
          showWidgets = {
            inStageManager = true;
            onDesktop = true;
          };
        };
        windows = {
          tiledWindowsHaveMargins = false;
        };
      };
      displays = {
        whenConnectedToTv = "Ask What to Show";
      };
      general = {
        languageAndRegion = {
          applications = { };
          preferredLanguages = [
            "en-US"
            "pt-PT"
          ];
          region = "en_US@rg=ptzzzz";
        };
        sharing = {
          mediaSharing = {
            shareMediaWithGuests = false;
          };
        };
      };
      keyboard = {
        delayUntilRepeat = 15;
        keyRepeatRate = 2;
        keyboardShortcuts = {
          accessibility = {
            decreaseContrast = false;
            increaseContrast = false;
            invertColors = false;
          };
          appShortcuts = {
            menuItems = {
              "All Applications" = {
                "this shit is retarded" = "⌘Q";
              };
            };
            showHelpMenu = "⇧⌘/";
          };
          inputSources = {
            selectNextSourceInInputMenu = "⌃⌥Space";
            selectThePreviousInputSource = false;
          };
          missionControl = {
            moveLeftASpace = true;
            moveRightASpace = true;
          };
          spotlight = {
            showFinderSearchWindow = false;
            showSpotlightSearch = false;
          };
        };
        textInput = {
          addPeriodWithDoubleSpace = true;
          capitalizeWordsAutomatically = true;
          inputSources = [
            "com.apple.keylayout.ABC"
            "com.apple.keylayout.Portuguese"
          ];
        };
      };
      menuBar = {
        clock = {
          showAmPm = true;
          showTheDayOfTheWeek = true;
        };
        display = "Don't Show";
        textInput = true;
        timeMachine = false;
      };
      privacyAndSecurity = {
        appleAdvertising = {
          personalizedAds = false;
        };
      };
      sound = {
        soundEffects = {
          alertSound = "Boop";
          alertVolume = 0.0;
          playFeedbackWhenVolumeIsChanged = false;
        };
      };
      spotlight = {
        searchResults = {
          appStore = true;
          apps = true;
          books = true;
          calculator = true;
          calendar = true;
          contacts = true;
          dictionary = true;
          files = true;
          folders = true;
          games = true;
          iPhoneApps = true;
          mail = true;
          menuItems = true;
          messages = true;
          music = true;
          notes = true;
          phone = true;
          photos = true;
          podcasts = true;
          reminders = true;
          safari = true;
          shortcuts = true;
          systemSettings = true;
          tips = true;
          voiceMemos = true;
        };
        showRelatedContent = true;
      };
      trackpad = {
        moreGestures = {
          appExpose = "Off";
          notificationCenter = true;
        };
        pointAndClick = {
          click = "Firm";
          forceClickAndHapticFeedback = true;
          lookUpAndDataDetectors = "Force Click with One Finger";
          tapToClick = true;
          trackingSpeed = 0.875;
        };
        scrollAndZoom = {
          naturalScrolling = true;
          rotate = true;
          smartZoom = true;
          zoomInOrOut = true;
        };
      };
    };
  };
}
