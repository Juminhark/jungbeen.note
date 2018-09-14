package jungbeen.note.page.controller;

import java.io.File;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import jungbeen.note.page.domain.Page;
import jungbeen.note.page.service.PageService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

@Controller
@RequestMapping("/page")
public class PageController {
	@Autowired private PageService pageService;
	
	@RequestMapping(method=RequestMethod.POST)
	public String page(HttpServletRequest request) {
		int noteId = Integer.parseInt(request.getParameter("noteId").trim());
		int idx = Integer.parseInt(request.getParameter("pageIdx").trim());
		
		Page selector = new Page();
		selector.setNoteId(noteId);
		selector.setIdx(idx);
		
		Page page = pageService.getPage(selector);
		request.setAttribute("page", page);
		
		return "page/page";
	}
	
	@RequestMapping("/upContent")
	@ResponseBody
	public boolean upContent(HttpServletRequest request) {
		int id = Integer.parseInt(request.getParameter("id"));
		String content1 = request.getParameter("content1");
		String content2 = request.getParameter("content2");
		String content3 = request.getParameter("content3");
		String content4 = request.getParameter("content4");
		String content5 = request.getParameter("content5");
		
		boolean success = false;
		
		if(content1 != null && !content1.equals("")) {
			Page alter = new Page();
			alter.setId(id);
			alter.setContent1(content1);
			alter.setContent2(content2);
			alter.setContent3(content3);
			alter.setContent4(content4);
			alter.setContent5(content5);
			success = pageService.editPage(alter);
		}		
		
		return success;
	}
	
	@RequestMapping("/downContent")
	@ResponseBody
	public List<Page> downContent(HttpServletRequest request) {
		int noteId = Integer.parseInt(request.getParameter("noteId"));
		List<Page> pages = pageService.getPages(noteId);
		return pages;
	}
	
	@RequestMapping(value="/upFile", method=RequestMethod.POST)
	@ResponseBody
	public String upload(MultipartFile uploadFile, HttpServletRequest request) {
		System.out.println(uploadFile);
		
		String dir = request.getSession().getServletContext().getRealPath("/upload");
		String fileName = uploadFile.getOriginalFilename();
		try {
			uploadFile.transferTo(new File(dir + "/" + fileName));
		} catch (Exception e) {}
		
		System.out.println(fileName);
		return fileName;
	}
}
