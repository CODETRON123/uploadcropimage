<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Title</title>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
<script type="text/javascript" src="http://cdn.rawgit.com/tapmodo/Jcrop/master/js/jquery.Jcrop.min.js"></script>



<!-- date created : 29-09 working properly, saving cropped image
     ISSUES :
     --------)> name saving with undefined in project save with question no, lesson,
     subject,class, if its option option number and same as above
-->
<!--
    ------------------------------------------------------- MAIN BLOCK COMMENT-----------------------------------------------------------------------------------------------
     This script is written to store cropped uploaded image to local storage in uploaded image format here is how its done
	 After user selects an image from choose file it goes to block1
	 When user clicks crop button then go to block 2
	 When user clicks upload image button go to block 3
	 -->
<script type="text/javascript">


/* ------------------------------------------------ START OF BLOCK 3 ---------------------------------------------------------------------------------------------*/
function actupload(){
	var data = new FormData();
	/* Here it will get blob from canvasToBlob method 
	   $('#imgCropped').val() has encoded image data and $('#imgCropped').val().split(";")[0].split("/")[1] has type of image png/jpeg/* 
	   generally $('#imgCropped').val() has value as data:image/png;base64,iVBORw0KGg....... */
    var blob = this.canvasToBlob($('#imgCropped').val(),$('#imgCropped').val().split(";")[0].split("/")[1]);
	/* blob store image and now blobname has no significance as it returns undefined and blobtype which is useful at server side code*/
	data.append("blob", blob);
    data.append("blobName",$('#imgCropped').val().name);
    data.append("blobType",$('#imgCropped').val().split(";")[0].split("/")[1]);
    /* here uploadtoserver stores/ copies image to local system*/
    this.uploadToServer(data);
}
function canvasToBlob(canvas,type){
	/* Here we convert canvas to blob 
	   atob(*) is used to decrypt string and we are sending/ returning blob */
	var byteString = atob(canvas.split(",")[1]);
    var ab = new ArrayBuffer(byteString.length);
    var ia = new Uint8Array(ab);
    var i;
	for (i = 0; i < byteString.length; i++) {
	    ia[i] = byteString.charCodeAt(i);
	}
	return new Blob([ab], {
	    type: type
	});
}
function uploadToServer(formData){
	/* With out really going on to other pages ang do the job we are using XMLHTTPREQUEST*/
	 xhr = new XMLHttpRequest();
	/* It goes to Fileupload.java POST method where it has code to save image in local system */
     xhr.open("post", "http://localhost:6060/cropupload/fileUpload", true);
     xhr.onreadystatechange = function() {
    	 /* readyatate == 4 request completed here not checking 404 and 200 codes */
         if (xhr.readyState == 4) {
             alert(xhr.responseText);
         }
     };
     xhr.send(formData);
}
/* ------------------------------------------------ END OF BLOCK 3 ---------------------------------------------------------------------------------------------*/



$(function () {
    $('#fileupload').change(function () {
    	
    	/* ------------------------------------------------ START OF BLOCK 1 ---------------------------------------------------------------------------------------------*/
      /**
    	*  We are hiding crop button and upload button initially and after change of file this is to remove ambiguity when user selects a crop image and changed file then 
    	*  that initial image which he selected will be saved when uploading so we are hiding crop and upload button along with canvas area
    	*/
        $('#btnCrop').hide();
        $('#btnupload').hide();
        $('#bb').hide();
        var reader = new FileReader();
        reader.onload = function (e) {
           /**
            * There is a reson for chosing set HTML tag if we move on with <img src ...... then a hidden div will be created and the newly image selected will go behind 
            * first selected image and when we crop we get newly selected image crop as we haven't selected with out seeing what is required re written code to clear
            * initial img tag and adding before setting src attribute
        	*/
    		$('#aa').html("<img id='Image1' src='' alt='' style='display: none' />");
          /*
           *  Setting src of img tag to selected image from file box
           */
            $('#Image1').attr("src", e.target.result);
          /*
           * Jcrop used for cropping when select it will update hidden fields to selected co ordinates to place image on canvas go to main block comment
           */
            $('#Image1').Jcrop({
                onChange: SetCoordinates,
                onSelect: SetCoordinates
            });
        }
        reader.readAsDataURL($(this)[0].files[0]);
    });
  /*---------------------------------------------------------------- END OF BLOCK 1 --------------------------------------------------------------------------------------*/
  
  
  /*---------------------------------------------------------------- START OF BLOCK 2 --------------------------------------------------------------------------------------*/
    $('#btnCrop').click(function () {
    	/* Here the crop image will be shown */
    	$('#bb').show();
    	/* Gets image boarder's from hidden form fields which we set using setcoordinates */
        var x1 = $('#imgX1').val();
        var y1 = $('#imgY1').val();
        var width = $('#imgWidth').val();
        var height = $('#imgHeight').val();
        var canvas = $("#canvas")[0];
        /* render 2D object */
        var context = canvas.getContext('2d');
        var img = new Image();
        img.onload = function () {
            canvas.height = height;
            canvas.width = width;
            /* Draw 2D object with in following dimensions*/
            context.drawImage(img, x1, y1, width, height, 0, 0, width, height);
            /* Here we are setting encoded image string to hidden form field imageCropped */
            $('#imgCropped').val(canvas.toDataURL());
            /* To show upload button as we have cropped image go to MAIN BLOCK*/
            $('[id*=btnupload]').show();
        };
        img.src = $('#Image1').attr("src");
    });
});
/*---------------------------------------------------------------- END OF BLOCK 2 --------------------------------------------------------------------------------------*/
function SetCoordinates(c) {
    $('#imgX1').val(c.x);
    $('#imgY1').val(c.y);
    $('#imgWidth').val(c.w);
    $('#imgHeight').val(c.h);
    $('#btnCrop').show();
}
</script>
</head>
<body>
<form>
	<input type="file" name="pic" id="fileupload" accept="image/*" />
	 <table border="0" cellpadding="0" cellspacing="5">
	    <tr>
	        <td id="aa">
	            <!-- <img id="Image1" src="" alt="" style="display: none" /> -->
	        </td>
	    </tr>
	    <tr>
	        <td id="bb">
	            <canvas id="canvas" height="5" width="5"></canvas>
	        </td>
	    </tr>
	</table>
	<input type="button" id="btnCrop" value="Crop" style="display: none" />
	<input type="button" id="btnupload" value="upload" style="display: none" onclick="actupload()" />
	<input type="hidden" name="imgX1" id="imgX1" />
	<input type="hidden" name="imgY1" id="imgY1" />
	<input type="hidden" name="imgWidth" id="imgWidth" />
	<input type="hidden" name="imgHeight" id="imgHeight" />
	<input type="hidden" name="imgCropped" id="imgCropped" />
</form>
</body>
</html>