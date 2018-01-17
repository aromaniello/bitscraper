const StatusList = ({ twitter_statuses }) => (
	<table class="table table-striped">
	  <thead>
	    <tr>
	      <th scope="col">id</th>
	      <th scope="col">week</th>
	      <th scope="col">status url</th>
	      <th scope="col">post date</th>
	      <th scope="col">parse date</th>
	    </tr>
	  </thead>
	  <tbody>
	    {twitter_statuses.map(({id, week, twitter_url, post_date, created_at}) =>
	    	<tr key={id}>
	        <th scope="row">{id}</th>
	        <td>{week}</td>
	        <td>
	        	<a href={twitter_url}>{twitter_url.replace('https://twitter.com/','')}</a>
	        </td>
	        <td>{post_date}</td>
	        <td>{created_at}</td>
	      </tr>
	    )}
	  </tbody>
	</table>
)
