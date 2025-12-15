#!/bin/zsh

set -euo pipefail

test_directory="${0:A:h}"
ios_directory="${test_directory:h:h}"
source_directory="$ios_directory/songmanager"
temporary_directory="$(mktemp -d /tmp/releasekit-siri-workflow-tests.XXXXXX)"
trap 'rm -rf "$temporary_directory"' EXIT

swiftc \
  -module-cache-path "$temporary_directory/module-cache" \
  -parse-as-library \
  "$source_directory/Models/AppModels.swift" \
  "$source_directory/AppIntents/SiriRoleChange.swift" \
  "$source_directory/AppIntents/SiriRoleSet.swift" \
  "$source_directory/AppIntents/SiriRoleChangeConfirmationFormatter.swift" \
  "$source_directory/AppIntents/SiriAttentionFilter.swift" \
  "$source_directory/AppIntents/SiriPercentageFormatter.swift" \
  "$source_directory/AppIntents/SiriSplitPreview.swift" \
  "$source_directory/AppIntents/SiriAttachAllocationConfirmationFormatter.swift" \
  "$source_directory/AppIntents/SiriSongSplitValidator.swift" \
  "$source_directory/AppIntents/SiriSongSummaryFormatter.swift" \
  "$source_directory/AppIntents/SiriReadinessFormatter.swift" \
  "$source_directory/AppIntents/SiriAttentionFormatter.swift" \
  "$test_directory/main.swift" \
  -o "$temporary_directory/SiriWorkflowTests"

"$temporary_directory/SiriWorkflowTests"
