
import java.io.File;
import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet(urlPatterns = { "/uploadservlet", "/fileUpload" })
@MultipartConfig(fileSizeThreshold=1024*1024*10, 	// 10 MB 
maxFileSize=1024*1024*50,      	// 50 MB
maxRequestSize=1024*1024*100) //100MB

public class Fileupload extends HttpServlet {
	private static final long serialVersionUID = 1L;
    public Fileupload() {
        super();
    }
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
    	
    }
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
    	/* We can store MIME data as PART*/
    	Part part = request.getPart("blob");
		String fileName = null;
		String fileType = null;
		if (part != null) {
			// writing blob
			fileName = request.getParameter("blobName");
			fileType = request.getParameter("blobType");
			
			part.write("D:" + File.separator + fileName+"."+fileType);

		} else {
			// Writing image or file
			part = request.getPart("file");
			fileName = getFileName(part);
			part.write("D:" + File.separator + fileName+"."+fileType);
		}

		// Extra logic to support multiple domain - you may want to remove this
		response.setHeader("Access-Control-Allow-Origin", "*");
		response.getWriter().print(fileName + " uploaded successfully");
    }
    private String getFileName(Part part) {
		String contentDisp = part.getHeader("content-disposition");
		System.out.println("content-disposition header= " + contentDisp);
		String[] tokens = contentDisp.split(";");
		for (String token : tokens) {
			if (token.trim().startsWith("filename")) {
				return token.substring(token.indexOf("=") + 2, token.length() - 1);
			}
		}
		return "";
	}
}
