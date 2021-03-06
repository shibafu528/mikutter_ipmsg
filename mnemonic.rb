# coding: utf-8

# constants from ipmsg.h
module Plugin::IPMsg::Mnemonic

  # command
  BR_ENTRY   = 0x00000001
  BR_EXIT    = 0x00000002
  ANSENTRY   = 0x00000003
  BR_ABSENCE = 0x00000004
  BR_NOTIFY  = BR_ABSENCE

  BR_ISGETLIST  = 0x00000010
  BR_OKGETLIST  = 0x00000011
  GETLIST       = 0x00000012
  ANSLIST       = 0x00000013
  BR_ISGETLIST2 = 0x00000018

  SENDMSG    = 0x00000020
  RECVMSG    = 0x00000021
  READMSG    = 0x00000030
  DELMSG     = 0x00000031
  ANSREADMSG = 0x00000032

  GETINFO  = 0x00000040
  SENDINFO = 0x00000041

  GETABSENCEINFO  = 0x00000050
  SENDABSENCEINFO = 0x00000051

  GETFILEDATA  = 0x00000060
  RELEASEFILES = 0x00000061
  GETDIRFILES  = 0x00000062

  GETPUBKEY = 0x00000072
  ANSPUBKEY = 0x00000073

  # option for all command
  ABSENCEOPT       = 0x00000100
  SERVEROPT        = 0x00000200
  DIALUPOPT        = 0x00010000
  FILEATTACHOPT    = 0x00200000
  ENCRYPTOPT       = 0x00400000
  UTF8OPT          = 0x00800000
  CAPUTF8OPT       = 0x01000000
  ENCEXTMSGOPT     = 0x04000000
  CLIPBOARDOPT     = 0x08000000
  CAPFILEENC_OBSLT = 0x00001000
  CAPFILEENCOPT    = 0x00040000

  # option for SENDMSG command
  SENDCHECKOPT = 0x00000100
  SECRETOPT    = 0x00000200
  BROADCASTOPT = 0x00000400
  MULTICASTOPT = 0x00000800
  AUTORETOPT   = 0x00002000
  RETRYOPT     = 0x00004000
  PASSWORDOPT  = 0x00008000
  NOLOGOPT     = 0x00020000
  NOADDLISTOPT = 0x00080000
  READCHECKOPT = 0x00100000
  SECRETEXOPT  = READCHECKOPT | SECRETOPT

  # option for GETDIRFILES/GETFILEDATA command
  ENCFILE_OBSLT = 0x00000400
  ENCFILEOPT    = 0x00000800

  # obsolete option for send command
  NEWMULTI_OBSLT = 0x00040000

end