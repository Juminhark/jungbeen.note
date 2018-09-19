package jungbeen.note.page.service;

import java.util.List;

import jungbeen.note.page.domain.Page;

public interface PageService {
	List<Page> getPages(int noteId);
	Page getPage(Page page);
	boolean addPage(Page page);
	boolean editPage(Page page);
	boolean delPage(Page page);
	
	int NEXTVAL();
}
