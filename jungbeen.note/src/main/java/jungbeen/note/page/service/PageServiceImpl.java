package jungbeen.note.page.service;

import java.util.List;

import jungbeen.note.page.dao.PageDao;
import jungbeen.note.page.domain.Page;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PageServiceImpl implements PageService {
	@Autowired private PageDao pageDao;
	
	@Override
	public List<Page> getPages(int noteId) {
		return pageDao.selectPages(noteId);
	}
	
	@Override
	public Page getPage(Page page) {
		return pageDao.selectPage(page);
	}
	
	@Override
	public boolean addPage(Page page) {
		return pageDao.insertPage(page) > 0;
	}
	
	@Override
	public boolean editPage(Page page) {
		return pageDao.updatePage(page) > 0;
	}
	
	@Override
	public boolean delPage(Page page) {
		return pageDao.deletePage(page) > 0;
	}
}
