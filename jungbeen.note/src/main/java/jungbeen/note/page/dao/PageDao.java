package jungbeen.note.page.dao;

import java.util.List;

import jungbeen.note.page.domain.Page;

public interface PageDao {
	List<Page> selectPages(int noteId);
	Page selectPage(Page page);
	int insertPage(Page page);
	int updatePage(Page page);
	int deletePage(Page page);
}
