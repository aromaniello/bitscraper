const BitcointalkUserList = ({ bitcointalk_users }) => (
	<table className="table table-striped">
	  <thead>
	    <tr>
	      <th scope="col">id</th>
	      <th scope="col">bitcointalk username</th>
	      <th scope="col">twitter user url</th>
	      <th scope="col">status count</th>
	      <th scope="col">most recent status update</th>
	    </tr>
	  </thead>
	  <tbody>
	  	{bitcointalk_users.map(({id, username, user_url, twitter_user_url, status_count, most_recent_status}) => 
	  		<tr key={id}>
	        <th scope="row">{id}</th>
	        <td>
	        	<a href={user_url}>{username}</a>
	        </td>
	        <td>
	        	<a href={twitter_user_url ? twitter_user_url : ""}>{twitter_user_url ? twitter_user_url.replace('https://twitter.com/','') : ""}</a>
	        </td>
	        <td>{status_count}</td>
	        <td>
	        	<a href={most_recent_status ? most_recent_status : ""}>{most_recent_status ? most_recent_status.replace('https://twitter.com/','') : ""}</a>
	        </td>
	      </tr>
	  	)}
	  </tbody>
	</table>
)
