<%@ page import="eu.sqooss.webui.*"
%><%@ page import="eu.sqooss.webui.view.*"
%><%@ page import="eu.sqooss.webui.widgets.*"
%><%
//============================================================================
// List all files in the selected project version
//============================================================================
if (selectedProject.isValid()) {
%>          <div id="fileslist" class="group">
<%
    selectedProject.retrieveData(terrier);
    Version selectedVersion = selectedProject.getCurrentVersion();
    if (selectedVersion != null) {
        // Check, if the user has switched to another directory
        if (request.getParameter("did") != null) {
            if (request.getParameter("did").equals("top"))
                selectedVersion.topDir();
            else if (request.getParameter("did").equals("prev"))
                selectedVersion.previousDir();
            else {
                Long directoryId = getId(request.getParameter("did"));
                if (directoryId != null)
                    selectedVersion.switchDir(directoryId);
            }
        }
        // Check, if the user has expanded/collapsed a directory
        if (request.getParameter("dst") != null) {
            Long directoryId = getId(request.getParameter("dst"));
            if (directoryId != null)
                selectedVersion.stateDir(directoryId);
        }
        // Check, if the user has enabled/disabled the results overview flag
        if (request.getParameter("showResults") != null) {
            if (request.getParameter("showResults").equals("true"))
                settings.setShowFileResultsOverview(true);
            else if (request.getParameter("showResults").equals("false"))
                settings.setShowFileResultsOverview(false);
        }
        // Check, if the user has deselected a metric
        if (request.getParameter("fvdm") != null) {
            Long metricId = getId(request.getParameter("fvdm"));
            if (metricId != null)
                selectedProject.deselectMetric(metricId);
        }
        //====================================================================
        // Display the selected file verbosely
        //====================================================================
        if (request.getParameter("fid") != null) {
            // Display a verbose information about the selected file
            Long fileId = strToLong(request.getParameter("fid"));
            VerboseFileView verboseView =
                new VerboseFileView(selectedProject, fileId);
            verboseView.setTerrier(terrier);
            verboseView.setServletPath(request.getServletPath());
            verboseView.setSettings(settings);
            // Check if the user asks for a comparison with another version
            if (request.getParameter("cvnum") != null) {
                verboseView.compareAgainst(
                    strToLong(request.getParameter("cvnum")));
            }
            icoCloseWin = new WinIcon();
            icoCloseWin.setPath(request.getServletPath());
            icoCloseWin.setImage("/img/icons/16x16/application-exit.png");
            icoCloseWin.setAlt("Close");
            Window winFileVerbose = new Window();
            winFileVerbose.setTitle("Source file results");
            winFileVerbose.addTitleIcon(icoCloseWin);
            winFileVerbose.setContent(verboseView.getHtml(in));
            out.print(winFileVerbose.render(in));
        }
        //====================================================================
        // Display a file browser for the selected project version
        //====================================================================
        else {
            // Retrieve the list of files, if not yet done
            selectedVersion.setTerrier(terrier);
            selectedVersion.setSettings(settings);
            selectedVersion.getFilesInCurrentDirectory();
            // Construct the window's content
            Window winFileBrowser = new Window();
            StringBuilder b = new StringBuilder("");
            // Check if this version is empty
            if (selectedVersion.isEmptyVersion()) {
                b.append(sp(in) + Functions.information(
                    "No files found in this project version!"));
            }
            // Construct a file browser for the selected project version
            else {
                // Retrieve results from all selected metrics, if requested
                if (selectedVersion.isEmptyDir() == false) {
                    if (settings.getShowFileResultsOverview()) {
                        selectedVersion.fetchFilesResults(
                            selectedProject.getSelectedMetrics());
                    }
                }

                // Show result icons
                WinIcon icoResults = new WinIcon();
                icoResults.setPath(request.getServletPath());
                icoResults.setParameter("showResults");
                icoResults.setStatus(
                    selectedProject.getSelectedMetrics().isEmpty() == false);
                if (settings.getShowFileResultsOverview()) {
                    icoResults.setValue("false");
                    icoResults.setAlt("Hide results");
                    icoResults.setImage("/img/icons/16x16/hide-statistics.png");
                }
                else {
                    icoResults.setValue("true");
                    icoResults.setAlt("Show results");
                    icoResults.setImage("/img/icons/16x16/view-statistics.png");
                }
                winFileBrowser.addToolIcon(icoResults);

                // Put a separator
                winFileBrowser.addToolIcon(icoSeparator);

                // Top folder icon
                WinIcon icoTopDir = new WinIcon();
                icoTopDir.setPath(request.getServletPath());
                icoTopDir.setParameter("did");
                icoTopDir.setValue("top");
                icoTopDir.setImage("/img/icons/16x16/go-first.png");
                icoTopDir.setAlt("Top folder");
                icoTopDir.setStatus(selectedVersion.isSubDir());
                winFileBrowser.addToolIcon(icoTopDir);

                // Previous folder icon
                WinIcon icoPrevDir = new WinIcon();
                icoPrevDir.setPath(request.getServletPath());
                icoPrevDir.setParameter("did");
                icoPrevDir.setValue("prev");
                icoPrevDir.setImage("/img/icons/16x16/go-previous.png");
                icoPrevDir.setAlt("Previous folder");
                icoPrevDir.setStatus(selectedVersion.isSubDir());
                winFileBrowser.addToolIcon(icoPrevDir);

                // Put a separator
                winFileBrowser.addToolIcon(icoSeparator);

                // Directory browser icon
                WinIcon icoDirBrowser = new WinIcon();
                icoDirBrowser.setPath(request.getServletPath());
                icoDirBrowser.setImage("/img/icons/16x16/browser.png");
                icoDirBrowser.setAlt("Directory browser");
                winVisible = "showFVDirBrowser";
                icoDirBrowser.setParameter(winVisible);
                icoDirBrowser.setValue(WinIcon.MAXIMIZE);
                if (request.getParameter(winVisible) != null) {
                    if (request.getParameter(winVisible).equals(WinIcon.MAXIMIZE))
                        settings.setShowFVDirBrowser(true);
                    else if (request.getParameter(winVisible).equals(WinIcon.MINIMIZE))
                        settings.setShowFVDirBrowser(false);
                }
                icoDirBrowser.setValue("" + !settings.getShowFVDirBrowser());
                icoDirBrowser.setStatus(!settings.getShowFVDirBrowser());
                winFileBrowser.addToolIcon(icoDirBrowser);

                // Folders list icon
                WinIcon icoFoldersList = new WinIcon();
                icoFoldersList.setPath(request.getServletPath());
                icoFoldersList.setImage("/img/icons/16x16/folder.png");
                icoFoldersList.setAlt("Show sub-folders");
                winVisible = "showFVFolderList";
                icoFoldersList.setParameter(winVisible);
                icoFoldersList.setValue(WinIcon.MAXIMIZE);
                if (request.getParameter(winVisible) != null) {
                    if (request.getParameter(winVisible).equals(WinIcon.MAXIMIZE))
                        settings.setShowFVFolderList(true);
                    else if (request.getParameter(winVisible).equals(WinIcon.MINIMIZE))
                        settings.setShowFVFolderList(false);
                }
                icoFoldersList.setValue("" + !settings.getShowFVFolderList());
                icoFoldersList.setStatus(!settings.getShowFVFolderList());
                winFileBrowser.addToolIcon(icoFoldersList);

                // Folders list icon
                WinIcon icoFilesList = new WinIcon();
                icoFilesList.setPath(request.getServletPath());
                icoFilesList.setImage("/img/icons/16x16/text-plain.png");
                icoFilesList.setAlt("Show files");
                winVisible = "showFVFileList";
                icoFilesList.setParameter(winVisible);
                icoFilesList.setValue(WinIcon.MAXIMIZE);
                if (request.getParameter(winVisible) != null) {
                    if (request.getParameter(winVisible).equals(WinIcon.MAXIMIZE))
                        settings.setShowFVFileList(true);
                    else if (request.getParameter(winVisible).equals(WinIcon.MINIMIZE))
                        settings.setShowFVFileList(false);
                }
                icoFilesList.setValue("" + !settings.getShowFVFileList());
                icoFilesList.setStatus(!settings.getShowFVFileList());
                winFileBrowser.addToolIcon(icoFilesList);

                // Put a separator
                winFileBrowser.addToolIcon(icoSeparator);

                Version vFirst = selectedProject.getFirstVersion();
                Version vLast = selectedProject.getLastVersion();
                Version vCurrent = selectedProject.getCurrentVersion();
                // First version icon
                WinIcon icoFirstVersion = new WinIcon();
                icoFirstVersion.setImage("/img/icons/16x16/first-revision.png");
                icoFirstVersion.setAlt("First version");
                if (vFirst != null) {
                    icoFirstVersion.setPath(request.getServletPath());
                    icoFirstVersion.setParameter("version" + selectedProject.getId());
                    icoFirstVersion.setValue(vFirst.getNumber().toString());
                }
                else {
                    icoFirstVersion.setStatus(false);
                }
                winFileBrowser.addToolIcon(icoFirstVersion);
                // Previous version icon
                WinIcon icoPrevVersion = new WinIcon();
                icoPrevVersion.setImage("/img/icons/16x16/prev-revision.png");
                icoPrevVersion.setAlt("Previous version");
                if ((vFirst != null) && (vCurrent != null)
                        && (vFirst.getNumber().equals(vCurrent.getNumber()) == false)) {
                    icoPrevVersion.setPath(request.getServletPath());
                    icoPrevVersion.setParameter("version" + selectedProject.getId());
                    icoPrevVersion.setValue("" + (vCurrent.getNumber() - 1));
                }
                else {
                    icoPrevVersion.setStatus(false);
                }
                winFileBrowser.addToolIcon(icoPrevVersion);
                // Next version icon
                WinIcon icoNextVersion = new WinIcon();
                icoNextVersion.setImage("/img/icons/16x16/next-revision.png");
                icoNextVersion.setAlt("Next version");
                if ((vLast != null) && (vCurrent != null)
                        && (vLast.getNumber().equals(vCurrent.getNumber()) == false)) {
                    icoNextVersion.setPath(request.getServletPath());
                    icoNextVersion.setParameter("version" + selectedProject.getId());
                    icoNextVersion.setValue("" + (vCurrent.getNumber() + 1));
                }
                else {
                    icoNextVersion.setStatus(false);
                }
                winFileBrowser.addToolIcon(icoNextVersion);
                // Last version icon
                WinIcon icoLastVersion = new WinIcon();
                icoLastVersion.setImage("/img/icons/16x16/last-revision.png");
                icoLastVersion.setAlt("Last version");
                if (vLast != null) {
                    icoLastVersion.setPath(request.getServletPath());
                    icoLastVersion.setParameter("version" + selectedProject.getId());
                    icoLastVersion.setValue(vLast.getNumber().toString());
                }
                else {
                    icoLastVersion.setStatus(false);
                }
                winFileBrowser.addToolIcon(icoLastVersion);
                // Version select widget
                if (selectedProject.countVersions() > 1) {
                    TextInput icoVerSelect = new TextInput();
                    icoVerSelect.setPath(request.getServletPath());
                    icoVerSelect.setParameter("version" + selectedProject.getId());
                    icoVerSelect.setValue(vCurrent.getNumber().toString());
                    icoVerSelect.setText("Version:");
                    winFileBrowser.addToolIcon(icoVerSelect);
                }

                // Prepare the shared close icon
                icoCloseWin = new WinIcon();
                icoCloseWin.setPath(request.getServletPath());
                icoCloseWin.setImage("/img/icons/16x16/application-exit.png");
                icoCloseWin.setAlt("Close");
                icoCloseWin.setValue(WinIcon.MINIMIZE);

                // Sub-views table
                in += 2;
                b.append(sp(in++) + "<table>\n");
                b.append(sp(in++) + "<tr>\n");
                //============================================================
                // Display the directory browser
                //============================================================
                if (settings.getShowFVDirBrowser()) {
                    if ((settings.getShowFVFolderList() == false)
                        && (settings.getShowFVFileList() == false))
                        b.append(sp(in++) + "<td"
                            + " style=\"width: 100%; vertical-align: top;\">\n");
                    else
                        b.append(sp(in++) + "<td"
                            + " style=\"width: 30%; vertical-align: top;\">\n");
                    Window winDirBrowser = new Window();
                    // Construct the window's title icons
                    Window winFileVerbose = new Window();
                    winVisible = "showFVDirBrowser";
                    icoCloseWin.setParameter(winVisible);
                    winDirBrowser.addTitleIcon(icoCloseWin);
                    // Construct the window's content
                    if (settings.getShowFVDirBrowser()) {
                        DirBrowserView dirBrowserView =
                            new DirBrowserView(selectedVersion.directories);
                        dirBrowserView.setServletPath(
                            request.getServletPath());
                        dirBrowserView.setSelectedDir(
                            selectedVersion.getCurrentDir());
                        winDirBrowser.setContent(
                            dirBrowserView.getHtml(in + 2));
                    }
                    // Display the window
                    winDirBrowser.setTitle("Source folders");
                    b.append(winDirBrowser.render(in));
                    b.append(sp(--in) + "</td>\n");
                }
                //============================================================
                // Display the folders and/or files in the selected directory
                //============================================================
                if (settings.getShowFVDirBrowser())
                    b.append(sp(in++) + "<td"
                        + " style=\"width: 70%; vertical-align: top;\">\n");
                else
                    b.append(sp(in++) + "<td"
                        + " style=\"width: 100%; vertical-align: top;\">\n");
                // Display the sub-folders of the current folder
                if (settings.getShowFVFolderList()) {
                    Window winFoldersList = new Window();
                    FileListView foldersView = new FileListView(
                        selectedVersion.files, FileListView.FOLDERS);
                    foldersView.setProject(selectedProject);
                    foldersView.setVersionId(selectedVersion.getId());
                    foldersView.setSettings(settings);
                    foldersView.setServletPath(request.getServletPath());
                    winVisible = "showFVFolderList";
                    icoCloseWin.setParameter(winVisible);
                    winFoldersList.addTitleIcon(icoCloseWin);
                    winFoldersList.setContent(foldersView.getHtml(in + 2));
                    winFoldersList.setTitle("Sub-folders in "
                        + selectedVersion.getCurrentDirName());
                    b.append(winFoldersList.render(in));
                }
                // Display the files in the current folder
                if (settings.getShowFVFileList()) {
                    Window winFilesList = new Window();
                    FileListView filesView = new FileListView(
                        selectedVersion.files, FileListView.FILES);
                    filesView.setProject(selectedProject);
                    filesView.setVersionId(selectedVersion.getId());
                    filesView.setSettings(settings);
                    filesView.setServletPath(request.getServletPath());
                    winVisible = "showFVFileList";
                    icoCloseWin.setParameter(winVisible);
                    winFilesList.addTitleIcon(icoCloseWin);
                    winFilesList.setContent(filesView.getHtml(in + 2));
                    winFilesList.setTitle("Files in "
                        + selectedVersion.getCurrentDirName());
                    b.append(winFilesList.render(in));
                }
            }
            b.append(sp(--in) + "</td>\n");
            b.append(sp(--in) + "</tr>\n");
            // Close the sub-views table
            b.append(sp(--in) + "</table>\n");
            // Display the window
            winFileBrowser.setContent(b.toString());
            winFileBrowser.setTitle("Files in version "
                + selectedVersion.getNumber());
            out.print(winFileBrowser.render(6));
        }
    }
    else
        out.print(sp(in) + Functions.information(
            "Please select a project version first."));
}
//============================================================================
// Let the user choose a project, if none was selected
//============================================================================
else {
%>          <div id="projectslist" class="group">
<%
    // Check if the user has selected a project
    if (request.getParameter("pid") != null)
        ProjectsListView.setCurrentProject(
            strToLong(request.getParameter("pid")));
    // Retrieve the list of projects from the connected SQO-OSS framework
    ProjectsListView.retrieveData(terrier);
    if (ProjectsListView.hasProjects()) {
        ProjectsListView.setServletPath(request.getServletPath());
        Window winPrjList = new Window();
        winPrjList.setTitle("Evaluated projects");
        winPrjList.setContent(ProjectsListView.getHtml(in + 2));
        out.print(winPrjList.render(in));
    }
    // No evaluated projects found
    else {
        out.print(sp(in) + Functions.information(
                "Unable to find any evaluated projects."));
    }
}
%>          </div>
