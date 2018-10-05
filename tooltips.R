register_mouseover_events <- function(session) {
  onevent("mouseenter", "upto", show_help_text("u", session))
  onevent("mouseleave", "upto", remove_help_text(session))
  
  onevent("mouseenter", "skip", show_help_text("s", session))
  onevent("mouseleave", "skip", remove_help_text(session))
  
  onevent("mouseenter", "typeOfQualityValues", show_help_text(c("phred33-quals", "phred64-quals", "int-quals"), session))
  onevent("mouseleave", "typeOfQualityValues", remove_help_text(session))
  
  onevent("mouseenter", "trim5", show_help_text("5", session))
  onevent("mouseleave", "trim5", remove_help_text(session))

  onevent("mouseenter", "trim3", show_help_text("3", session))
  onevent("mouseleave", "trim3", remove_help_text(session))

  onevent("mouseenter", "alignmentType", show_help_text(c("end-to-end", "local"), session))
  onevent("mouseleave", "alignmentType", remove_help_text(session))

  onevent("mouseenter", "endToEndPresets", show_help_text(c("very-fast", "fast", "sensitive", "very-sensitive"), session))
  onevent("mouseleave", "endToEndPresets", remove_help_text(session))

  onevent("mouseenter", "localPresets", show_help_text(c("very-fast-local", "fast-local", "sensitive-local", "very-sensitive-local"), session))
  onevent("mouseleave", "localPresets", remove_help_text(session))

  onevent("mouseenter", "seedLen", show_help_text("L", session))
  onevent("mouseleave", "seedLen", remove_help_text(session))

  onevent("mouseenter", "interval", show_help_text("i", session))
  onevent("mouseleave", "interval", remove_help_text(session))

  onevent("mouseenter", "nCeil", show_help_text("n-ceil" , session))
  onevent("mouseleave", "nCeil", remove_help_text(session))

  onevent("mouseenter", "maxMM", show_help_text("N", session))
  onevent("mouseleave", "maxMM", remove_help_text(session))

  onevent("mouseenter", "dPad", show_help_text("dpad", session))
  onevent("mouseleave", "dPad", remove_help_text(session))

  onevent("mouseenter", "gBar", show_help_text("gbar", session))
  onevent("mouseleave", "gBar", remove_help_text(session))

  onevent("mouseenter", "ignoreQuals", show_help_text("ignore-quals", session))
  onevent("mouseleave", "ignoreQuals", remove_help_text(session))

  onevent("mouseenter", "noFw", show_help_text("nofw", session))
  onevent("mouseleave", "noFw", remove_help_text(session))

  onevent("mouseenter", "noRc", show_help_text("nofw", session))
  onevent("mouseleave", "noRc", remove_help_text(session))

  onevent("mouseenter", "no1MmUpfront", show_help_text("no-1mm-upfront", session))
  onevent("mouseleave", "no1MmUpfront", remove_help_text(session))

  onevent("mouseenter", "matchBonus", show_help_text("ma", session))
  onevent("mouseleave", "matchBonus", remove_help_text(session))

  onevent("mouseenter", "scoreMin", show_help_text("score-min", session))
  onevent("mouseleave", "scoreMin", remove_help_text(session))

  onevent("mouseenter", "maxPenalty", show_help_text("mp", session))
  onevent("mouseleave", "maxPenalty", remove_help_text(session))

  onevent("mouseenter", "nPenalty", show_help_text("np", session))
  onevent("mouseleave", "nPenalty", remove_help_text(session))

  onevent("mouseenter", "extendAttempts", show_help_text("D", session))
  onevent("mouseleave", "extendAttempts", remove_help_text(session))

  onevent("mouseenter", "seedCount", show_help_text("R", session))
  onevent("mouseleave", "seedCount", remove_help_text(session))

  onevent("mouseenter", "minIns", show_help_text("I", session))
  onevent("mouseleave", "minIns", remove_help_text(session))

  onevent("mouseenter", "maxIns", show_help_text("X", session))
  onevent("mouseleave", "maxIns", remove_help_text(session))

  onevent("mouseenter", "mateAlign", show_help_text("fr", session))
  onevent("mouseleave", "mateAlign", remove_help_text(session))

  onevent("mouseenter", "noDiscordant", show_help_text("no-discordant", session))
  onevent("mouseleave", "noDiscordant", remove_help_text(session))

  onevent("mouseenter", "noContain", show_help_text("no-contain", session))
  onevent("mouseleave", "noContain", remove_help_text(session))

  onevent("mouseenter", "omitSecSeq", show_help_text("omit-sec-seq", session))
  onevent("mouseleave", "omitSecSeq", remove_help_text(session))

  onevent("mouseenter", "samNoQnameTrunc", show_help_text("sam-no-qname-trunc", session))
  onevent("mouseleave", "samNoQnameTrunc", remove_help_text(session))

  onevent("mouseenter", "noSq", show_help_text("no-sq", session))
  onevent("mouseleave", "noSq", remove_help_text(session))

  onevent("mouseenter", "xEq", show_help_text("xeq", session))
  onevent("mouseleave", "xEq", remove_help_text(session))

  onevent("mouseenter", "softClippedUnmappedTlen", show_help_text("soft-clipped-unmapped-tlen", session))
  onevent("mouseleave", "softClippedUnmappedTlen", remove_help_text(session))

  onevent("mouseenter", "readsAreSequences", show_help_text("c", session))
  onevent("mouseleave", "readsAreSequences", remove_help_text(session))

  onevent("mouseenter", "inputFileFormat", show_help_text(c("q", "f", "tab5", "tab6"), session))
  onevent("mouseleave", "inputFileFormat", remove_help_text(session))
  
}
