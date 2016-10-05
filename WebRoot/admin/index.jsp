<%@page import="lib.*,java.util.ArrayList"%>
<%
	Config con = new Config();
	if(con.getConfig("password") == null)
		response.sendRedirect("../index.jsp");
	String loginerr = request.getParameter("error");
	if(loginerr == null)
		loginerr = "";

    String pdfPath = con.separate(con.getConfig("path.pdf", ""));

    if(session.getAttribute("FLEXPAPER_AUTH")!=null){
        String[] pdfFile = request.getParameterValues("pdfFile");
        if(pdfFile != null) {
            con.DeleteFiles(pdfFile, pdfPath);
        }
	}

	String id = request.getParameter("ADMIN_USERNAME");
	String name = request.getParameter("ADMIN_PASSWORD");
	if(id != null && name != null) {
		if(id.equals(con.getConfig("username", "")) && name.equals(con.getConfig("password", "")))
			session.setAttribute("FLEXPAPER_AUTH", "1");
		else{
			session.removeAttribute("FLEXPAPER_AUTH");
			loginerr = "Authentication failed. Please contact your system administrator for assistance.";
		}
	}
%>
<jsp:include page="../common/header.jsp"/>
<% if(session.getAttribute("FLEXPAPER_AUTH") == null) { %>
	<script type="text/javascript">
	$(document).ready(function(){
		$('#ADMIN_USERNAME').focus();
	});
	</script>
	<div id="underlay"></div>
	<div id="content">
		<img alt="devaldi lock" id="lock" src="../common/images/paper_lock.png" width="347" height="346" />
		<div class="right_column">
			<form action="index.jsp" class="devaldi" id="login" method="post">
				<h3>
					<nobr>Login to the FlexPaper Console</nobr>
				</h3>
				<label for="j_username">User</label>
				<div class="text">
					<input id="ADMIN_USERNAME" name="ADMIN_USERNAME" size="30" type="text" />
					<div class="effects"></div>
					<div class="loader"></div>
				</div>
				<label for="j_password">Password</label>
				<div class="text">
					<input id="ADMIN_PASSWORD" name="ADMIN_PASSWORD" size="30" type="password" />
					<div class="effects"></div>
					<div class="loader"></div>
				</div>
				<div id="loginResult" class="formError">
					<%=loginerr %>
				</div>
				<ol class="horiz_bttns">
					<li><button class="login small main n_button" type="submit"><span></span><em>Login</em></button></li>
				</ol>
				<p id="result"></p>
			</form>
		</div>
	</div>
<%} else { %>
<link href="../common/css/prettify.css" type="text/css" rel="stylesheet" />
<script type="text/javascript">
$(function() {
	$('table tbody tr').mouseover(function() {
		$(this).removeClass('checkedRow');
		$(this).removeClass('unselectedRow');
		$(this).addClass('selectedRow');
	}).mouseout(function() {
		if ($('input:first', this).attr('checked') == 'checked') {
			$(this).removeClass('selectedRow');
			$(this).addClass('checkedRow');
		}
		else {
			$(this).removeClass('selectedRow');
			$(this).addClass('unselectedRow');
			$(this).removeClass('checkedRow');
		}
	}).click(function(event){
		var tagName = (event && event.target)?event.target.tagName:window.event.srcElement.tagName;
		if(tagName != 'INPUT' && !jQuery(event.target).hasClass('title')){
			<% if(!"true".equals(con.getConfig("splitmode", ""))){ %>
				window.open('../common/simple_document.jsp?doc='+ $('input:first', this).val(),'open_window','menubar, toolbar, location, directories, status, scrollbars, resizable, dependent, width=640, height=480, left=0, top=0');
			<% }else{ %>
				window.open('../common/split_document.jsp?doc='+ $('input:first', this).val(),'open_window','menubar, toolbar, location, directories, status, scrollbars, resizable, dependent, width=640, height=480, left=0, top=0');
			<% } %>
		}else{
			if(tagName != 'INPUT')
				$('input:first', this).prop("checked", !($('input:first', this).attr('checked') == 'checked'));
		}
	});

    $('.file-upload').fileUpload(
    {
        url: 'upload.jsp',
        type: 'POST',
        dataType: 'json',
        beforeSend: function () {
            jQuery('#Filename').val(jQuery('#Filedata').val().substr(jQuery('#Filedata').val().lastIndexOf("\\")+1));
        },
        complete: function () {

        },
        success: function (result, status, xhr) {
            if(result=='0'){
                alert('Unable to upload file. Please verify your server directory permissions.');
            }else{
                window.location.reload(true);
            }
        }
    }
    );
});
</script> 
<script type="text/javascript" src="../common/js/pagination.js"></script>

	<div style="width:690px;clear:both;padding: 20px 10px 20px 10px;">
		<button class="tiny main n_button" type="submit"  onclick="location.href='../common/change_config.jsp'"><span></span><em style="min-width:150px"><img src="../common/images/icon16_configuration.gif" style="padding-top:2px;"/>&nbsp;Configuration</em></button>&nbsp;
	</div>

	<div style="clear:both;background-color:#fff;padding: 20px 10px 20px 30px;border:0px;-webkit-box-shadow: rgba(0, 0, 0, 0.246094) 0px 4px 8px 0px;min-width:900px;float:left;width:900px;margin-left:10px;margin-bottom:50px;">
		<h3>Available Documents</h3>
		<form method="post" action="index.jsp" enctype="multipart/form-data">
            <div style="float:left;position:absolute;">
                <div style="position:absolute;left:0px;top:0px;">
                    <input class="file-upload" type="file" name="Filedata" id="Filedata" style="font-size: 30px;width:115px;opacity:0;cursor: pointer;position:absolute;left:0;top:0;" />
                    <button class="tiny main n_button" type="submit" onclick="return false;" style="pointer-events:none;"><span></span><em style="min-width:100px"><input type="hidden" name="Filename" id="Filename" value="" /><img src="admin_files/images/upload.png" style="padding-top:2px;">&nbsp;Upload</em></button>
                    &nbsp;<br/>
                </div><div style="position:absolute;left:0px;top:0px;"><div id="file_upload" type="button"></div></div>
            </div>
			<div style="float:left;padding-left:120px;">
				<button class="tiny main n_button" onclick="return window.confirm('Are you sure you want to delete these files?');" type="submit"><span></span><em style="min-width:100px"><img src="../common/images/delete.png" style="padding-top:2px;" />&nbsp;Delete</em></button>&nbsp;
			</div>
			<div style="clear:both"><br/></div>
			<table style="width:880px" cellspacing="0" cellpadding="0" class="selectable_sortable">
<%
	ArrayList<String> arr = con.DirectoryFiles(pdfPath);
	for(int i = 0; i < arr.size(); i++){
		String fname = arr.get(i).toString();
		if(fname.endsWith(".pdf") && !fname.equals("Sample.pdf")) {
%>
				<tr class="unselectedRow">
					<th class="title" style="width:15px">
						<input type="checkbox" id="pdfFile" name="pdfFile" value="<%=fname%>" class="fileCheckBox" />
					</th>
					<td class="tr" style="text-align:left;">
						<%=fname%>
					</td>
					<td class="tr" style="text-align:left;">
						<%=con.getSizeString(con.FileSize(pdfPath, fname))%>
					</td>
				</tr>
		<%}
	}
	if(arr == null) {
%>
				<div style="padding-top:100px">
					Could not open directory listing. Make sure the web user has read and write permission to the PDF directory.
				</div>
<% } else if(arr.size() ==0){
	%>
				<div style="padding-top:100px">
					No files in PDF directory.
				</div>
<%}%>
			</table>
		</form>
		<div id="upload-queue" style="width:300px;height:50px;"></div>
		<script src="../common/js/prettify.js"></script>
		<script type="text/javascript">
			prettyPrint();
		</script>
<%
	String msg = request.getParameter("msg");
	if(msg != null){
%>			 			
		<div id="messagebox" style="width:300px;height:50px;">
			<img src="../common/images/info_icon.png" />&nbsp;
			<%=msg%>
		</div>
<%	} %>
	</div>
<%} %>
<jsp:include page="../common/footer.jsp"/>