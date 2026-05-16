;;; SPDX-License-Identifier: MPL-2.0
;;; SPDX-FileCopyrightText: 2024-2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
;;;
;;; Development environment for cyo.
;;;   guix shell -f guix.scm
;;;
;;; cyo has no build step; this provides the tools to render the chapters
;;; (asciidoctor / bat), check the scripts (shellcheck, bash), and lint
;;; SPDX/REUSE compliance.

(use-modules (guix packages)
             (gnu packages base)
             (gnu packages bash)
             (gnu packages ruby)
             (gnu packages rust-apps)
             (gnu packages code))

(packages->manifest
 (list bash
       coreutils
       ruby-asciidoctor
       bat
       shellcheck))
