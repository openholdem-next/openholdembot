//******************************************************************************
//
// This file is part of the OpenHoldem project
//    Source code:           https://github.com/OpenHoldem/openholdembot/
//    Forums:                http://www.maxinmontreal.com/forums/index.php
//    Licensed under GPL v3: http://www.gnu.org/licenses/gpl.html
//
//******************************************************************************
//
// Purpose:
//
//******************************************************************************

// DialogSAPrefs4.cpp : implementation file
//

#include "stdafx.h"

#include "SAPrefsSubDlg.h"
#include "DialogSAPrefs4.h"

#include "CScraper.h"

#include "..\DLLs\WindowFunctions_DLL\window_functions.h"

// CDlgSAPrefs4 dialog

IMPLEMENT_DYNAMIC(CDlgSAPrefs4, CSAPrefsSubDlg)

CDlgSAPrefs4::CDlgSAPrefs4(CWnd* pParent /*=NULL*/)
		: CSAPrefsSubDlg(CDlgSAPrefs4::IDD, pParent)
{
}

CDlgSAPrefs4::~CDlgSAPrefs4()
{
}

void CDlgSAPrefs4::DoDataExchange(CDataExchange* pDX)
{
	CSAPrefsSubDlg::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_SCRAPEDELAY, m_ScrapeDelay);
	DDX_Control(pDX, IDC_SCRAPEDELAY_SPIN, m_ScrapeDelay_Spin);
	DDX_Control(pDX, IDC_CAPTURE_METHOD, m_CaptureMethod);
}

BEGIN_MESSAGE_MAP(CDlgSAPrefs4, CSAPrefsSubDlg)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SCRAPEDELAY_SPIN, &CDlgSAPrefs4::OnDeltaposScrapedelaySpin)
END_MESSAGE_MAP()

// CDlgSAPrefs4 message handlers
BOOL CDlgSAPrefs4::OnInitDialog()
{
	CString		text = "";

	CSAPrefsSubDlg::OnInitDialog();

	text.Format("%d", Preferences()->scrape_delay());
	m_ScrapeDelay.SetWindowText(text);
	m_ScrapeDelay_Spin.SetRange(100, 5000);
	m_ScrapeDelay_Spin.SetPos(Preferences()->scrape_delay());
	m_ScrapeDelay_Spin.SetBuddy(&m_ScrapeDelay);

	// The order of these entries has to match the k_capture_method constants
	m_CaptureMethod.AddString("Classic (BitBlt)");
	m_CaptureMethod.AddString("PrintWindow");
	int capture_method = Preferences()->scrape_capture_method();
	if (capture_method < k_capture_method_bitblt
		|| capture_method > k_capture_method_printwindow) {
		capture_method = k_capture_method_printwindow;
	}
	m_CaptureMethod.SetCurSel(capture_method);

	return TRUE;  // return TRUE unless you set the focus to a control
	// EXCEPTION: OCX Property Pages should return FALSE
}

void CDlgSAPrefs4::OnOK()
{
	CString			text = "";

	m_ScrapeDelay.GetWindowText(text);
	if (strtoul(text.GetString(), 0, 10)<MIN_SCRAPEDELAY || strtoul(text.GetString(), 0, 10)>MAX_SCRAPEDELAY) {
		MessageBox_Interactive("Invalid Scrape Delay", "ERROR", MB_OK);
		return;
	}
	Preferences()->SetValue(k_prefs_scrape_delay, strtoul(text.GetString(), 0, 10));
	Preferences()->SetValue(k_prefs_scrape_capture_method, m_CaptureMethod.GetCurSel());

	CSAPrefsSubDlg::OnOK();
}

void CDlgSAPrefs4::OnDeltaposScrapedelaySpin(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);
	pNMUpDown->iDelta*=100;
	*pResult = 0;
}
